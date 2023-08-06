//
//  ContentView.swift
//  BetterRest
//
//  Created by Alex Nguyen on 2023-05-07.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepHours = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = "Your Ideal Bedtime"
    @State private var alertMessage = "0"
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60 // hour but in seconds
            let minute = (components.minute ?? 0) * 60 // minute in seconds
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepHours, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            return "Sorry, there was a problem."
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text(calculateBedtime())
                        .font(.system(size: 70))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                    
                } header: {
                    Text(alertTitle)
                }
                
                Section {
                    DatePicker("Pick a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                } header: {
                    Text("When to wake up?")
                }
                
                Section {
                    
                    Stepper("\(sleepHours.formatted()) hours", value: $sleepHours, in: 4...12, step: 0.25)
                    
                } header: {
                    Text("Desired hours of sleep")
                }
                
                Section {
                    Picker("Cups", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("\($0) \($0 == 1 ? "cup" : "cups")")
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("Daily coffee intake")
                }
                
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
