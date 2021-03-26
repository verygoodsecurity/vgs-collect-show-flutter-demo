//
//  ShowView.swift
//  Runner
//

import Foundation
import UIKit
import VGSShowSDK

/// Native UIView subclass, holds VGSLabels.
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

}
