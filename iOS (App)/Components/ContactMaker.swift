import Foundation
import ContactsUI
import SwiftUI

struct ContactMaker: UIViewControllerRepresentable {
typealias UIViewControllerType = CNContactViewController
    var contact: Binding<CNContact?>
    var presentingEditContact: Binding<Bool>

    func makeCoordinator() -> ContactMaker.Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactMaker>) -> ContactMaker.UIViewControllerType {
        let controller = CNContactViewController(forNewContact: contact.wrappedValue)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: ContactMaker.UIViewControllerType, context: UIViewControllerRepresentableContext<ContactMaker>) {
        //
    }

    // Nested coordinator class, the prefered way stated in SwiftUI documentation.
    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: ContactMaker

        init(_ contactDetail: ContactMaker) {
            self.parent = contactDetail
        }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            parent.contact.wrappedValue = contact ?? parent.contact.wrappedValue
            parent.presentingEditContact.wrappedValue = false
        }

        func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
            return true
        }
    }
}
