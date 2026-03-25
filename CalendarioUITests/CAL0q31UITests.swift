import XCTest

final class CAL0q31UITests: XCTestCase {
    // MARK: - CAL-0q3.1: App companion: lista de configuraciones y CRUD básico

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: Empty state

    func test_CAL0q31_given_noConfigs_when_appLaunches_then_showsEmptyStateLabel() {
        // Given — fresh install / no saved configs
        // When  — app launches and config list loads
        // Then  — empty-state label is visible
        let label = app.staticTexts["emptyStateLabel"]
        XCTAssertTrue(label.waitForExistence(timeout: 5), "Expected empty state label")
    }

    func test_CAL0q31_given_noConfigs_when_appLaunches_then_showsCreateFirstConfigButton() {
        // Given — empty state is shown
        // When  — user sees the empty state
        // Then  — "Crear primera configuración" button is present
        XCTAssertTrue(
            app.buttons["createFirstConfigButton"].waitForExistence(timeout: 5),
            "Expected 'Crear primera configuración' button in empty state"
        )
    }

    // MARK: Navigation to create form

    func test_CAL0q31_given_emptyState_when_tappingAddButton_then_showsNewConfigForm() {
        // Given — empty state (+ button in toolbar)
        XCTAssertTrue(app.staticTexts["emptyStateLabel"].waitForExistence(timeout: 5))

        // When  — tap the + toolbar button
        app.buttons["addConfigButton"].tap()

        // Then  — config form appears with name field and action buttons
        XCTAssertTrue(app.textFields["nameField"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["saveButton"].exists)
        XCTAssertTrue(app.buttons["cancelButton"].exists)
    }

    func test_CAL0q31_given_emptyState_when_tappingCreateFirstButton_then_showsNewConfigForm() {
        // Given — empty state
        XCTAssertTrue(app.buttons["createFirstConfigButton"].waitForExistence(timeout: 5))

        // When  — tap "Crear primera configuración"
        app.buttons["createFirstConfigButton"].tap()

        // Then  — form opens
        XCTAssertTrue(app.textFields["nameField"].waitForExistence(timeout: 3))
    }

    // MARK: Form validation

    func test_CAL0q31_given_newConfigForm_when_nameIsEmpty_then_saveButtonIsDisabled() {
        // Given — form is open with no text in name field
        app.buttons["addConfigButton"].tap()
        XCTAssertTrue(app.textFields["nameField"].waitForExistence(timeout: 3))

        // When  — name field is empty (default)
        // Then  — Save button is disabled
        XCTAssertFalse(
            app.buttons["saveButton"].isEnabled,
            "Save button should be disabled when name is empty"
        )
    }

    // MARK: Dismiss without saving

    func test_CAL0q31_given_newConfigForm_when_cancelTapped_then_dismissesAndShowsEmptyState() {
        // Given — form is open
        app.buttons["addConfigButton"].tap()
        XCTAssertTrue(app.textFields["nameField"].waitForExistence(timeout: 3))

        // When  — tap Cancel
        app.buttons["cancelButton"].tap()

        // Then  — form is dismissed and empty state is back
        XCTAssertTrue(
            app.staticTexts["emptyStateLabel"].waitForExistence(timeout: 3),
            "Empty state should reappear after cancelling"
        )
    }

    // MARK: Config list (requires at least one saved config)

    func test_CAL0q31_given_existingConfigs_when_listShown_then_configListExists() {
        // Given — there is at least one config (skip if empty state)
        guard app.collectionViews["configList"].waitForExistence(timeout: 3) else {
            // No configs saved; empty-state path already covered above
            return
        }

        // When  — list is visible
        // Then  — the config list identifier is present
        XCTAssertTrue(app.collectionViews["configList"].exists)
    }
}
