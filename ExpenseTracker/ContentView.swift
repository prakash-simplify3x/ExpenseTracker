//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by User on 13/10/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) var context
    @State private var isShowingItemSheet = false
    @Query(sort: \Expense.date) var expenses: [Expense] = []
//    var expenses: [Expense]= []
    @State private var expenseToEdit: Expense?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { expense in
                    ExpenseCell(expense: expense)
                        .onTapGesture {
                            expenseToEdit = expense
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(expenses[index])
                    }}
            }
//            .navigationTitle("Expense Tracker")
//            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingItemSheet) { AddExpenseSheet() }
            .sheet(item: $expenseToEdit) { expense in UpdateExpenseSheet(expense: expense)
            }
//            .toolbar {
//                if !expenses.isEmpty {
//                    Button ("Add Expense", systemImage: "plus") {
//                        isShowingItemSheet = true
//                    }
//                }
//            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Expense Tracker")
                        .font(.largeTitle)    // Increase the font size
                        .fontWeight(.bold)    // Make it bold
                        .padding(.top, 20)    // Adjust the padding to move the title down
                        .accessibilityAddTraits(.isHeader)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !expenses.isEmpty {
                        Button {
                            isShowingItemSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .overlay {
                if expenses.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No Expenses", systemImage: "list.bullet.rectangle.portrait")
                    }, description: {
                        Text("Start adding expenses to see your list.")
                    }, actions: {
                        Button("Add Expense") { isShowingItemSheet = true}
                    })
                    .offset(y: -60)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

struct ExpenseCell: View {
    
    let expense: Expense
    
    var body: some View {
        HStack {
            Text(expense.date, format: .dateTime.month(.abbreviated).day()).frame(width: 70, alignment: .leading)
            Text(expense.name)
            Spacer()
            Text(expense.value, format: .currency(code: "INR"))
        }
    }
}

struct AddExpenseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var date: Date = .now
    @State private var value: Double = 0
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Expense name", text: $name)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Value", value: $value, format: .currency(code: "INR"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        // Save code goes here
                        let expense = Expense(name: name, date: date, value: value)
                        context.insert(expense)
//                        try! context.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct UpdateExpenseSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Bindable var expense: Expense
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Expense name", text: $expense.name)
                DatePicker("Date", selection: $expense.date, displayedComponents: .date)
                TextField("Value", value: $expense.value, format: .currency(code: "INR"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Update Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
