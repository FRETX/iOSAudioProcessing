//
//  ParameterAnalyzer.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 26/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class ParameterAnalyzer:NSObject{
    
    internal let output:Float
    internal var enabled:Bool
    internal var parameterAnalyzers:[ParameterAnalyzer]
    
    override init(){
        self.enabled = false
        self.output = -1
        self.parameterAnalyzers = []
    }
    
    public func process(input:Float){
        
    }
    
    public func addParameterAnalyzer(pa:ParameterAnalyzer){
        self.parameterAnalyzers.append(pa)
    }
    
    public func removeParameterAnalyzerAt(index:Int){
        self.parameterAnalyzers.remove(at: index)
    }
    
    internal func internalProcess(){
        
    }
    
    internal func processingFinished(){
        
    }
    
    internal func sendOutput(){
        for pa in parameterAnalyzers {
            pa.process(input: output)
        }
    }
    
    public func enable(){
        enabled = true
    }
    
    public func disable(){
        enabled = false
    }
    
}
