//
//  FlutterShowView.swift
//  Runner
//

import Foundation
import Flutter
import UIKit
import VGSShowSDK

class FlutterShowView: NSObject, FlutterPlatformView {

	let showView: ShowView
	let messenger: FlutterBinaryMessenger
	let channel: FlutterMethodChannel
	let viewId: Int64

	init(messenger: FlutterBinaryMessenger,
			 frame: CGRect,
			 viewId: Int64,
			 args: Any?) {
		self.messenger = messenger
		self.viewId = viewId
		self.showView = ShowView()

		channel = FlutterMethodChannel(name: "card-show-form-view/\(viewId)",
																			 binaryMessenger: messenger)

		super.init()

		channel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
			switch call.method {
			case "revealCard":
					self.showView.revealCard(with: call, result: result)
			default:
					result(FlutterMethodNotImplemented)
			}
		})
	}

	public func sendFromNative(_ text: String) {
		 channel.invokeMethod("sendFromNative", arguments: text)
	 }

	public func view() -> UIView {
	 return showView
	}
}

class ShowView: UIView {

	let vgsShow = VGSShow(id: DemoAppConfig.shared.vaultId, environment: .sandbox)

  // MARK: - Vars

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical

		stackView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		stackView.distribution = .fill
		stackView.spacing = 16
		return stackView
	}()

	private lazy var cardNumberVGSLabel: VGSLabel = {
		let label = VGSLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.placeholder = "Card number"
		label.font = UIFont.systemFont(ofSize: 14)
		label.placeholderStyle.color = .black
		label.placeholderStyle.textAlignment = .center
		label.textAlignment = .center

		label.contentPath = "json.payment_card_number"

		return label
	}()

	private lazy var expirationDateLabel: VGSLabel = {
		let label = VGSLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 14)
		label.placeholder = "Expiration date"
		label.placeholderStyle.color = .black
		label.placeholderStyle.textAlignment = .center
		label.textAlignment = .center

		label.contentPath = "json.payment_card_expiration_date"

		return label
	}()

	// MARK: - Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(stackView)
		stackView.pinToSuperviewEdges()
		stackView.addArrangedSubview(cardNumberVGSLabel)
		stackView.addArrangedSubview(expirationDateLabel)

		vgsShow.subscribe(cardNumberVGSLabel)
		vgsShow.subscribe(expirationDateLabel)

		cardNumberVGSLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
		expirationDateLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

  // MARK: - Public

	func revealCard(with flutterMethodCall: FlutterMethodCall, result: @escaping FlutterResult)  {
		cardNumberVGSLabel.backgroundColor = .orange
		var errorInfo: [String : Any] = [:]
		var payload: [String : Any] = [:]
		guard let args = flutterMethodCall.arguments as? [Any],
					let cardToken = args.first as? String, let expDateToken = args[safe: 1] as? String
		else {
			errorInfo["show_error_code"] = 999
			errorInfo["show_error_message"] = "No payload to reveal. Collect some data first!"

			result(errorInfo)
			return
		}

		cardNumberVGSLabel.backgroundColor = .green
		payload["payment_card_number"] = cardToken
		payload["payment_card_expiration_date"] = expDateToken

		vgsShow.request(path: DemoAppConfig.shared.path,
										method: .post, payload: payload) { (requestResult) in

			switch requestResult {
			case .success(let code):
				var successInfo: [String : Any] = [:]
				successInfo["show_status_code"] = code

				result(successInfo)
			case .failure(let code, let error):
				errorInfo["show_error_code"] = code
				if let message = error?.localizedDescription {
					errorInfo["show_error_message"] = message
				}

				result(errorInfo)
			}
		}
	}
}

extension Collection {
		/// Returns the element at the specified index if it is within bounds, otherwise nil.
		subscript (safe index: Index) -> Element? {
				return indices.contains(index) ? self[index] : nil
		}
}
