//
//  ViewController.swift
//  RazorPayDemo
//
//  Created by HS on 01/11/20.
//

import Razorpay
import UIKit

class ViewController: UIViewController {
    @IBOutlet var amountTF: UITextField!
    var razorpay: RazorpayCheckout!
    private let testKey = "rzp_test_lAQjBGYqCzFRvu"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        razorpay = RazorpayCheckout.initWithKey(testKey, andDelegate: self)
    }

    @IBAction func payTap(_ sender: UIButton) {
        if let amount = amountTF.text, amount != "", amount.count > 0 {
            createOrder(with: amount)
        } else {
            print("please enter amount in correct formate")
        }
    }

    // create order
    private func createOrder(with amount: String) {
        let url = URL(string: "http://localhost:8000/create-order?amt=\(amount)")!

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("Order created successfully: \(String(describing: json))\n")
                if let orderId = json?["id"] as? String, let amount = json?["amount_due"] as? Int {
                    print("Order id is: \(orderId)")

                    let options: [String: Any] = [
                        "amount": amount, // This is in currency subunits. 100 = 100 paise= INR 1.
                        "currency": "INR", // We support more that 92 international currencies.
                        "description": "outsourcing IT Services",
                        "order_id": orderId,
                        "image": "https://url-to-image.png",
                        "name": "HS Consultants",
                        "prefill": [
                            "contact": "9650530761",
                            "email": "harendra2008gwl@gmail.com",
                        ],
                        "theme": [
                            "color": "#F37254",
                        ],
                    ]

                    DispatchQueue.main.async {
                        self.razorpay.open(options)
                    }
                } else {
                    print("oops..! cannot process your order")
                }
            } catch {
                print("oops..! cannot process your order")
            }
        }

        task.resume()
    }
}

extension ViewController: RazorpayPaymentCompletionProtocol {
    public func onPaymentError(_ code: Int32, description str: String) {
        let alertController = UIAlertController(title: "FAILURE", message: str, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    public func onPaymentSuccess(_ payment_id: String) {
        let alertController = UIAlertController(title: "SUCCESS", message: "Payment Id \(payment_id)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
