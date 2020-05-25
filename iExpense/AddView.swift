//
//  AddView.swift
//  iExpense
//
//  Created by Myat Thu Ko on 5/24/20.
//  Copyright © 2020 Myat Thu Ko. All rights reserved.
//

import SwiftUI

struct AddView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var expenses: Expenses
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    static let types = ["Personal", "Business"]
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    ForEach(Self.types, id: \.self) {
                        Text($0)
                    }
                }
                
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
            .navigationBarTitle("Add a new expense")
            .navigationBarItems(trailing:
                Button("Save") {
                    guard let actualAmount = Double(self.amount) else {
                        self.alertMessage = "The amount must be a number."
                        self.showAlert.toggle()
                        return
                    }
                    guard !self.name.isEmpty else {
                        self.alertMessage = "Pleaes provide the item name."
                        self.showAlert.toggle()
                        return
                    }
                    let item = ExpenseItem(name: self.name, type: self.type, amount: actualAmount)
                    self.expenses.items.append(item)
                    //this line is needed to trigger the save button and solve the bug
                    self.expenses.items = self.expenses.items
                    self.presentationMode.wrappedValue.dismiss()
            })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("Okay")))
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
