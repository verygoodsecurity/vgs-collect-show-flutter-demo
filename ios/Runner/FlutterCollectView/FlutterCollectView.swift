//
//  FlutterCollectView.swift
//  Runner
//

import Foundation
import Flutter
import UIKit
import VGSCollectSDK

class FlutterCollectViewFactory: NSObject, FlutterPlatformViewFactory {

  // MARK: - Private vars

	private var messenger: FlutterBinaryMessenger

	// MARK: - Initialization

	init(messenger: FlutterBinaryMessenger) {
		self.messenger = messenger
	}

	// MARK: - Public

	public func create(withFrame frame: CGRect,
										 viewIdentifier viewId: Int64,
										 arguments args: Any?) -> FlutterPlatformView {
		return FlutterCollectView(messenger: messenger,
															frame: frame, viewId: viewId,
															args: args)
	}
	public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
		return FlutterStandardMessageCodec.sharedInstance()
	}
}

class FlutterCollectView: NSObject, FlutterPlatformView {

	let collectView: CollectView
	let messenger: FlutterBinaryMessenger
	let channel: FlutterMethodChannel
	let viewId: Int64

	init(messenger: FlutterBinaryMessenger,
			 frame: CGRect,
			 viewId: Int64,
			 args: Any?) {
		self.messenger = messenger
		self.viewId = viewId
		self.collectView = CollectView()

		channel = FlutterMethodChannel(name: "card-collect-form-view/\(viewId)",
																			 binaryMessenger: messenger)

		super.init()

		channel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
			switch call.method {
			case "redactCard":
				self.collectView.redactCard(with: result)
			default:
				result(FlutterMethodNotImplemented)
			}
		})
	}

	public func sendFromNative(_ text: String) {
		 channel.invokeMethod("sendFromNative", arguments: text)
	 }

	public func view() -> UIView {
	 return collectView
	}
}

class CollectView: UIView {

  // MARK: - Vars

	let vgsCollect = VGSCollect(id: DemoAppConfig.shared.vaultId, environment: .sandbox)

	lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical

		stackView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		stackView.distribution = .fill
		stackView.spacing = 16
		return stackView
	}()

	lazy var cardNumberField: VGSCardTextField = {
		let field = VGSCardTextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.placeholder = "Card number"
		field.font = UIFont.systemFont(ofSize: 12)
		field.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

		let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "cardNumber")
		field.configuration = cardConfiguration

		return field
	}()

	lazy var expDateField: VGSExpDateTextField = {
		let field = VGSExpDateTextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

		field.font = UIFont.systemFont(ofSize: 12)
		// Update validation rules

		let expDateConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "expDate")
		expDateConfiguration.isRequiredValidOnly = true
		expDateConfiguration.type = .expDate

		// Default .expDate format is "##/##"
		expDateConfiguration.formatPattern = "##/####"
		expDateConfiguration.validationRules = VGSValidationRuleSet(rules: [
			VGSValidationRuleCardExpirationDate(dateFormat: .longYear, error: VGSValidationErrorType.expDate.rawValue)
		])

		field.configuration = expDateConfiguration
		field.placeholder = "MM/YYYY"
		field.monthPickerFormat = .longSymbols

		return field
	}()

	// MARK: - Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(stackView)
		stackView.pinToSuperviewEdges()
		stackView.addArrangedSubview(cardNumberField)
		stackView.addArrangedSubview(expDateField)

		cardNumberField.heightAnchor.constraint(equalToConstant: 60).isActive = true
		expDateField.heightAnchor.constraint(equalToConstant: 60).isActive = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public

	func redactCard(with result: @escaping FlutterResult)  {
		cardNumberField.backgroundColor = .yellow
		vgsCollect.sendData(path: "/post", extraData: nil) { [weak self](response) in
			switch response {
			case .success(_, let data, _):
				if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

					print("SUCCESS: \(jsonData)")
					if let aliases = jsonData["json"] as? [String: Any],
						let cardNumber = aliases["cardNumber"],
						let expDate = aliases["expDate"] {

						let payload = ["cardNumber": cardNumber,
													 "expDate": expDate]
						result(payload)
					}
				}
				return
			case .failure(let code, _, _, let error):
				var errorInfo: [String : Any] = [:]
				errorInfo["collect_error_code"] = code

				if let message = error?.localizedDescription {
					errorInfo["collect_error_message"] = message
				}
				switch code {
				case 400..<499:
					// Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
					print("Error: Wrong Request, code: \(code)")
				case VGSErrorType.inputDataIsNotValid.rawValue:
					if let error = error as? VGSError {
						print("Error: Input data is not valid. Details:\n \(error)")
					}
				default:
					print("Error: Something went wrong. Code: \(code)")
				}
				print("Submit request error: \(code), \(String(describing: error))")

				result(errorInfo)
				return
			}
		}
	}
}
