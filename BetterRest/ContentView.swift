//
//  ContentView.swift
//  BetterRest
//
//  Created by Sucias Colomer, David on 13/7/21.
//

import SwiftUI

struct ContentView: View {
    let model = SleepCalculator()
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 2
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    let coffeeCapsOption = [1,2,3,4,5]
    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                        .onChange(of: wakeUp, perform: { _ in
                            calculateBedtime()
                        })

                }
                

                Section(header: Text("Desired amount of sleep")){
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                    .onChange(of: sleepAmount, perform: { _ in
                        calculateBedtime()
                    })
                }
                
                Section(header: Text("Daily coffee intake")) {
                    
                    Picker("Tip percentage", selection: $coffeeAmount) {
                        ForEach( 0 ..< coffeeCapsOption.count) {
                            Text("\(self.coffeeCapsOption[$0])")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: coffeeAmount, perform: { _ in
                        calculateBedtime()
                    })
                }
            }
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                                    HStack {
                                        Text("Go to bed at: ")
                                        Text("\(alertMessage)")
                                            .foregroundColor(Color.green)
                                            .fontWeight(.bold)
                                            .font(.title)
                                    }
            )
        }
    }
    
    func calculateBedtime() {
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            alertMessage = formatter.string(from: sleepTime)
        } catch {
            alertMessage = "Error..."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
