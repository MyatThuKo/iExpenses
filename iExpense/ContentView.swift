//
//  ContentView.swift
//  iExpense
//
//  Created by Myat Thu Ko on 5/23/20.
//  Copyright © 2020 Myat Thu Ko. All rights reserved.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Double
}

struct checkAmount: View {
    var text: String
    var amount: Double
    
    var body: some View {
        if amount < 10 {
            return Text(text)
                .foregroundColor(.gray)
        } else if (amount > 10 && amount < 101) {
            return Text(text)
                .foregroundColor(.green)
        } else {
            // amount > 100
            return Text(text)
                .foregroundColor(.red)
        }
    }
}

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }
        
        self.items = []
    }
}

struct ContentView: View {
    @ObservedObject var expense = Expenses()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expense.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        Spacer()
                        checkAmount(text: "$\(item.amount)", amount: item.amount)
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton(), trailing:
                Button(action: {
                    self.showingAddExpense = true 
                }) {
                    Image(systemName: "plus")
                }
            )
                .sheet(isPresented: $showingAddExpense) {
                    AddView(expenses: self.expense)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expense.items.remove(atOffsets: offsets)
        //this line is added to fix the bug
        expense.items = expense.items
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//This is the resource to fix the bug.
//https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented/61311279#61311279
