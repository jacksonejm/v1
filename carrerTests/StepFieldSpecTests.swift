import XCTest
@testable import carrer

class StepFieldSpecTests: XCTestCase {
    
    var spec: StepFieldSpec!
    
    override func setUpWithError() throws {
        // Load the spec for testing
        guard let loadedSpec = StepFieldSpec.load() else {
            XCTFail("Failed to load StepFieldSpec.json")
            return
        }
        spec = loadedSpec
    }
    
    func testOrderMatchesSteps() {
        // Verify that all steps in the order array exist in the steps dictionary
        let stepKeys = Set(spec.steps.keys)
        let orderSet = Set(spec.order)
        
        XCTAssertEqual(spec.order.count, orderSet.count, "Order array should not contain duplicates")
        XCTAssertTrue(stepKeys.isSuperset(of: orderSet), "All steps in order should exist in steps dictionary")
    }
    
    func testRequiredFieldsExist() {
        // Verify that all required fields for each step exist in the fields dictionary
        for (stepKey, stepSpec) in spec.steps {
            for requiredField in stepSpec.required {
                XCTAssertTrue(stepSpec.fields.contains(requiredField), 
                              "Required field \(requiredField) should be in fields list for step \(stepKey)")
                XCTAssertNotNil(spec.fields[requiredField], 
                                "Required field \(requiredField) should exist in fields dictionary")
            }
        }
    }
    
    func testNextStepsExist() {
        // Verify that all nextStep values (except "dashboard") exist in the steps dictionary
        for (stepKey, stepSpec) in spec.steps {
            if stepSpec.nextStep != "dashboard" {
                XCTAssertTrue(spec.steps.keys.contains(stepSpec.nextStep), 
                              "NextStep \(stepSpec.nextStep) for step \(stepKey) should exist")
            }
        }
    }
    
    func testFieldsHaveValidTypes() {
        // Verify field types match their configuration
        for (fieldKey, fieldSpec) in spec.fields {
            switch fieldSpec.type {
            case .selection, .multiSelection:
                XCTAssertNotNil(fieldSpec.options, "Selection field \(fieldKey) should have options")
                XCTAssertFalse(fieldSpec.options?.isEmpty ?? true, "Selection field \(fieldKey) should have non-empty options")
                
            case .ratings:
                XCTAssertNotNil(fieldSpec.questions, "Ratings field \(fieldKey) should have questions")
                XCTAssertFalse(fieldSpec.questions?.isEmpty ?? true, "Ratings field \(fieldKey) should have non-empty questions")
                XCTAssertNotNil(fieldSpec.minRating, "Ratings field \(fieldKey) should have minRating")
                XCTAssertNotNil(fieldSpec.maxRating, "Ratings field \(fieldKey) should have maxRating")
                
            case .string:
                // String fields may have min/max length constraints
                if let minLength = fieldSpec.minLength, let maxLength = fieldSpec.maxLength {
                    XCTAssertTrue(minLength <= maxLength, "Min length should be <= max length for \(fieldKey)")
                }
                
            default:
                break
            }
        }
    }
    
    func testDependentFieldsExist() {
        // Verify that dependent fields exist
        for (fieldKey, fieldSpec) in spec.fields {
            if let dependency = fieldSpec.dependsOn {
                XCTAssertTrue(spec.fields.keys.contains(dependency.field), 
                              "Dependency field \(dependency.field) for \(fieldKey) should exist")
                
                if let includes = dependency.includes {
                    let parentField = spec.fields[dependency.field]
                    XCTAssertTrue(parentField?.options?.contains(includes) ?? false,
                                 "Dependency value \(includes) should be an option in parent field \(dependency.field)")
                }
            }
        }
    }
}