CREATE DATABASE gamification;

\c gamification

DROP TABLE IF EXISTS activity;
DROP TABLE IF EXISTS "user";
DROP TABLE IF EXISTS achievement;

CREATE TABLE "user" (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR NOT NULL,
    points INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT current_timestamp,
    last_update TIMESTAMP NOT NULL DEFAULT current_timestamp
);

CREATE TABLE achievement (
    id VARCHAR(65) PRIMARY KEY,
    name VARCHAR(128),
    description VARCHAR NOT NULL
);

CREATE TABLE game_mode (
    id INTEGER PRIMARY KEY,
    name VARCHAR(32)
);

CREATE TABLE activity (
    id SERIAL PRIMARY KEY,
    "user" VARCHAR(36) NOT NULL,
    achievement VARCHAR(65) NOT NULL,
    points INTEGER NOT NULL,
    game_mode INTEGER NOT NULL,
    timestamp timestamp NOT NULL DEFAULT current_timestamp,

    CONSTRAINT user_activity_fk FOREIGN KEY("user") REFERENCES "user"(id),
    CONSTRAINT achievement_activity_fk FOREIGN KEY(achievement) REFERENCES achievement(id),
    CONSTRAINT game_mode_activity_fk FOREIGN KEY(game_mode) REFERENCES game_mode(id)
);

CREATE TABLE coverage(
     id SERIAL PRIMARY KEY,
     "user" VARCHAR(36) NOT NULL,
     total_class_count INTEGER NOT NULL,
     covered_class_count INTEGER NOT NULL,
     total_method_count INTEGER NOT NULL,
     covered_method_count INTEGER NOT NULL,
     total_line_count INTEGER NOT NULL,
     covered_line_count INTEGER NOT NULL,
     total_branch_count INTEGER NOT NULL,
     covered_branch_count INTEGER NOT NULL,
     tested_class VARCHAR(128) NOT NULL,
     test_name VARCHAR(128) NOT NULL,
     game_mode INTEGER NOT NULL,
     created_at TIMESTAMP NOT NULL DEFAULT current_timestamp,

    CONSTRAINT user_coverage_fk FOREIGN KEY("user") REFERENCES "user"(id),
    CONSTRAINT game_mode_coverage_fk FOREIGN KEY(game_mode) REFERENCES game_mode(id)
);

CREATE OR REPLACE FUNCTION user_last_update()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.last_update := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_last_update BEFORE UPDATE ON "user" FOR EACH ROW EXECUTE FUNCTION user_last_update();


INSERT INTO achievement (id, name, description) VALUES('AddTestsAchievement', 'Safety First', 'Create X tests');
INSERT INTO achievement (id, name, description) VALUES('CoverXBranchesAchievement', 'Check your branches', 'Cover X branches with your tests. Attention: for this achievement the tracing option of the IntelliJ Runner must be enabled.');
INSERT INTO achievement (id, name, description) VALUES('CoverXClassesAchievement', 'Check your classes', 'Cover X classes with your tests');
INSERT INTO achievement (id, name, description) VALUES('CoverXLinesAchievement', 'Line-by-line', 'Cover X lines with your tests');
INSERT INTO achievement (id, name, description) VALUES('CoverXMethodsAchievement', 'Check your methods', 'Cover X methods with your tests');
INSERT INTO achievement (id, name, description) VALUES('FindXBugsAchievement', 'Bug Finder', 'Find bugs in the code with your tests. Your test code should be the same between the first failed test run and the first successful run.');
INSERT INTO achievement (id, name, description) VALUES('GetXBranchCoverageInClassesWithYBranchesAchievement', 'Class Reviewer - Branches', 'Cover 5 classes which have at least 15 branches by at least 75.0%. Attention: for this achievement the tracing option of the IntelliJ Runner must be enabled.');
INSERT INTO achievement (id, name, description) VALUES('GetXLineCoverageInClassesWithYLinesAchievement', 'Class Reviewer - Lines', 'Cover 5 classes which have at least 5 lines by at least 70.0%');
INSERT INTO achievement (id, name, description) VALUES('GetXMethodCoverageInClassesWithYMethodsAchievement', 'Class Reviewer - Methods', 'Cover 10 classes which have at least 3 methods by at least 60.0%');
INSERT INTO achievement (id, name, description) VALUES('RefactorAddXAssertionsAchievement', 'Double check', 'Add assertions to your tests.');
INSERT INTO achievement (id, name, description) VALUES('RefactorCodeAchievement', 'Shine in new splendour', 'Refactor test code between two consecutive passing test runs.');
INSERT INTO achievement (id, name, description) VALUES('RefactorExtractXMethodsAchievement', 'The Method Extractor', 'Extract methods');
INSERT INTO achievement (id, name, description) VALUES('RefactorInlineXMethodsAchievement', 'The Method Inliner', 'Inline methods');
INSERT INTO achievement (id, name, description) VALUES('RefactorXTestNamesAchievement', 'The Eponym', 'Give your tests better names');
INSERT INTO achievement (id, name, description) VALUES('RepairXWrongTestsAchievement', 'Test Fixer', 'Repair wrong tests');
INSERT INTO achievement (id, name, description) VALUES('RunWithCoverageAchievement', 'Gotta Catch ’Em All', 'Run your tests with coverage');
INSERT INTO achievement (id, name, description) VALUES('RunXDebuggerModeAchievement', 'The Debugger', 'You get this achievement by using the debug mode.');
INSERT INTO achievement (id, name, description) VALUES('RunXTestsAchievement', 'Test Executor', 'Every single test execution counts as progress');
INSERT INTO achievement (id, name, description) VALUES('RunXTestSuitesAchievement', 'The Tester', 'Can be achieved by running tests');
INSERT INTO achievement (id, name, description) VALUES('RunXTestSuitesWithXTestsAchievement', 'The Tester - Advanced', 'Run 10 times test suites containing at least 100 tests');
INSERT INTO achievement (id, name, description) VALUES('SetXBreakpointsAchievement', 'Take some breaks', 'Can be achieved by setting breakpoints');
INSERT INTO achievement (id, name, description) VALUES('SetXConditionalBreakpointsAchievement', 'Make Your Choice', 'Can be achieved by setting conditional breakpoints');
INSERT INTO achievement (id, name, description) VALUES('SetXFieldWatchpointsAchievement', 'On the Watch', 'Can be achieved by setting field watchpoints');
INSERT INTO achievement (id, name, description) VALUES('SetXLineBreakpointsAchievement', 'Break the Line', 'Can be achieved by setting line breakpoints');
INSERT INTO achievement (id, name, description) VALUES('SetXMethodBreakpointsAchievement', 'Break the Method', 'Can be achieved by setting method breakpoints');
INSERT INTO achievement (id, name, description) VALUES('TriggerXAssertsByTestsAchievement', 'Assert and Tested', 'Asserts have to be successfully passed by tests');

INSERT INTO game_mode (id, name) VALUES(0, 'Leaderboard');
INSERT INTO game_mode (id, name) VALUES(1, 'Achievements');
