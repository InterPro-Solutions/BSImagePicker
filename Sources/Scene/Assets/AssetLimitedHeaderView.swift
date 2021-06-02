// The MIT License (MIT)
//
// Copyright (c) 2021 Xiang Li
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos

@available(iOS 14, *)
class AssetLimitedHeaderView : UICollectionReusableView {
    weak var  titleLabel : UILabel!
    weak var  manageButton : UIButton!
    weak var parentController : UIViewController?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.customInit()
    }

    func customInit(){
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakStrategy = .pushOut
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.paragraphStyle : paragraphStyle
        ]
        label.attributedText = NSMutableAttributedString(string: "You have allowed access to a pre-selected subset of photos and videos.  Select \"Manage\" to update this list.", attributes: titleAttributes)
        label.numberOfLines = 0
        self.titleLabel = label

        let button = UIButton(type: .system)
        self.manageButton = button
        let buttonAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
        ]
        let buttonAttritbutedString = NSMutableAttributedString(string: "Manage", attributes: buttonAttributes)
        button.setAttributedTitle(buttonAttritbutedString, for: .normal)
        button.addTarget(self, action: #selector(tappedManageButton(_:)), for: .touchUpInside)
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.addSubview(button)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            button.widthAnchor.constraint(equalToConstant: buttonAttritbutedString.size().width+10)
        ])
        button.sizeToFit()
    }

    @objc func tappedManageButton(_ button:UIButton){
        guard let controller = self.parentController else {return}
        let actionSheet = UIAlertController(title: "",
                                            message: "Select more photos or go to Settings to allow access to all photos.",
                                            preferredStyle: .actionSheet)

        let selectPhotosAction = UIAlertAction(title: "Select more photos",
                                               style: .default) { [weak self] (_) in
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
        }
        actionSheet.addAction(selectPhotosAction)

        let allowFullAccessAction = UIAlertAction(title: "Allow access to all photos",
                                                  style: .default) { [weak self] (_) in
            // Open app privacy settings
            guard let self = self else {return}
            self.gotoAppPrivacySettings()
        }
        actionSheet.addAction(allowFullAccessAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        if let popoverController = actionSheet.popoverPresentationController {
          popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
            popoverController.permittedArrowDirections = [.up,.right]
        }
        controller.present(actionSheet, animated: true, completion: nil)
    }

    func calculateHeight(_ width:CGFloat) -> CGFloat{
        guard
            let titleAttributesString = self.titleLabel.attributedText,
            let buttonAttritbutedString = self.manageButton.attributedTitle(for: .normal)
        else {
            return 40
        }
        let rect = titleAttributesString.boundingRect(with: CGSize(width: width-buttonAttritbutedString.size().width-40, height: 1000), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
        let result = rect.height+20
        return result > 40 ? result : 40
    }

    private func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
