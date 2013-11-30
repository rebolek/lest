Test framework documentation
	Author: Ladislav Mecir

=toc

===Introduction

This document describes the core test framework available at

=url https://github.com/rebolsource/rebol-test

The test file format has been originally designed by Carl Sassenrath to be:

* Rebol compatible
* as simple as possible

===Types of tests

The test framework supports unit testing of:

* Rebol interpreter (or compiler) core
* Rebol function libraries

GUI testing is not supported yet.

===How to run the tests?

Example running core-tests in my machine with Microsoft Windows 8:

    e:\Ladislav\rebol\rebol-view.exe -s run-recover.r

My current local directory when running the tests is e:\Ladislav\rebol-test.

The test framework needs a path to the interpreter executable to be able to calculate interpreter checksum.  

It is possible to give the run-recover.r script an argument. If the full path to the interpreter executable isn't obtained from the command line, the argument of the run-recover.r script, if given, is used as the path to the executable.

If the path to the executable is not available using any of the above methods, the test framework checksums to value of the system/build variable instead.

Example running core-tests in my Kubuntu machine:

    ladislav@lkub64:/rebol-test$ /r3/make/r3 run-recover.r

(my current local directory when running the tests is /rebol-test)

Don't worry when the program (either the test framework or the interpreter) crashes (in the core-tests suite there are some tests crashing the interpreter), just run the tests again the same way as before:

    e:\Ladislav\rebol\rebol-view.exe -s run-recover.r

or

    ladislav@lkub64:/rebol-test$ /r3/make/r3 run-recover.r

Until the testing finishes. After testing was finished, calling run-recover.r again does not do anything.

===Log file name

The result of the test is a log file named like:

   r_2_7_8_3_1_1DEF65_E85A1B.log

(this is my run-recover.r result in Windows 8 running the official 2.7.8.3.1 interpreter) or

    r_2_101_0_4_4_F9A855_E85A1B.log

(this is my run-recover.r result in Kubuntu runnning my build of the 2.101.0.4.4 interpreter).

The first character of the log file name, #"r" is common to all run-recover log files. The next part describes the version of the interpreter, the following 6 characters are a part of the interpreter executable checksum, and the last 6 characters preceding the file extension are a part of the core-tests.r file checksum.

As you can notice from the checksums, I used the same version of the core-tests.r file in both examples.

===Summary

The summary (can be found at the end of the log file) I obtained was:

    system/version: 2.7.8.3.1
    interpreter-checksum: #{1DEF65DDE53AB24C122DA6C76646A36D7D910790}
    test-checksum: #{E85A1B2945437E38E7654B9904937821C8F2FA92}
    Total: 4598
    Succeeded: 3496
    Test-failures: 156
    Crashes: 7
    Dialect-failures: 0
    Skipped: 939

in the former case and

    system/version: 2.101.0.4.4
    interpreter-checksum: #{F9A855727FE738149B8E769C37A542D4E4C8FF82}
    test-checksum: #{E85A1B2945437E38E7654B9904937821C8F2FA92}
    Total: 4598
    Succeeded: 4136
    Test-failures: 142
    Crashes: 15
    Dialect-failures: 0
    Skipped: 305

in the latter.

As you can see, the test-checksums and the total number of the tests are equal. That is because we used the same version of the tests.

However, the numbers of succeeded tests, failed tests, crashing tests and skipped tests differ.

The reason why the number of skipped tests differ is that 2.7.8 is R2 while 2.101.0 is R3. These interpreter versions are different in many aspects and it does not make sense to perform some R2 tests in R3 environment and vice versa, which leads to the necessity to skip some tests depending on the interpreter type.

The "Dialect failures" number counts the cases when the test framework found incorrectnesses in the test file, cases when the test file was not written in accordance with the formatting rules described below.

If you get more than zero dialect failures, you should correct the respective test file.

===Log file contents

The tests in the log file are always text-copies of the tests from the test file, which means that they are not modified in any way. It is possible to run them in REBOL console as well as to find them using text search in the test file if desired.

Note that if the tests weren't text-copies, but just molded (using either MOLD or MOLD/ALL) versions of the tests, the text search would not be guaranteed to work. (Furthermore, in some cases such modified tests would work differently.)

===Filtering test logs

Sometimes we are not interested in all test results preferring to see only a list of failed tests. The log-filter.r script can be used for that as follows:

    e:\Ladislav\rebol\rebol-view.exe log-filter.r r_2_7_8_3_1_1DEF65_E85A1B.log

The result is the file:

    f_2_7_8_3_1_1DEF65_E85A1B.log

, i.e., the file having a prefix #"f", otherwise having the same name as the original log file and containing just the list of failed tests.

===Comparing test logs

We have seen that we obtained different test summaries for different interpreter versions. There is a log-diff.r script allowing us to obtain the list and summary of the differences between two log files.

The log-diff.r script can be run as follows:

    e:\Ladislav\rebol\rebol-view.exe log-diff.r r_2_7_8_3_1_1 DEF65_E85A1B.log r_2_101_0_4_4_F9A855_E85A1B.log

The first log file given is the "old log file" and the second file is "new log file".

The result is the diff.r file containing the list of the tests with different results and the summary as follows:

    new-successes: 907
    new-failures: 25
    new-crashes: 4
    progressions: 119
    regressions: 94
    removed: 302
    unchanged: 3147
    total: 4598

Where, again, we see that the total number of tests was 4598. The count of "new- successes" expresses how many successful tests were newly performed (performed in the new log, but not performed in the old log), the count of "new-failures" expresses how many failing tests were newly performed, "new-crashes" expresses how many crashing tests were newly performed, the count of "progressions" expresses how many tests have improved results and the number of "regressions" expresses how many tests have worse results than before, "removed" expresses how many tests are not performed in the new log, "unchanged" expresses how many tests have the same result both in the old and in the new log.

Log difference is useful if:

* We want to know the effect of interpreter code update. In this case it is most convenient (but not required) to perform the same test suite in both the old as well as the new interpreter version.
* We want to know the effect of test suite changes. In this case it is most convenient (but not required) to perform both the old and new test suite version using the same interpreter and compare the logs.

===Features of the test dialect

* In accordance with Carl's design intention, the test dialect is "Rebol compatible" and as simple as possible.
* However, the test dialect is not handled by the test framework as Rebol code, because the tests contained in the test suite can be (and actually are) used to test different Rebol interpreters (both R2 and R3 in our case), every one of them having a different "idea" what "Rebol" is.
* The fact that the test environment handles the test file as formatted text (i.e., not as Rebol code) complicates test file parsing a bit (not too much since the format was designed by Carl Sassenrath to be simple), but it brings significant advantages:
** One test file can be used to test different (more or less source-code compatible) interpreters.
** One of the properties that can be and actually is tested is the ability of the interpreter to load the test as Rebol code.
** Since the test file is handled by the test framework as a text file having the format described below, the test framework is able to always record/handle the original "look" of the tests.
** Therefore, the original tests cannot be "distorted" by any incorrect LOAD/MOLD transformation performed by the interpreter.
** Tests "stand for themselves" not needing any names. (Test writers can use whatever naming convention they prefer, but names are not required for the test framework to be able to handle the tests.)
** Log files can be further postprocessed
** There is a sophisticated log-diff function tailor-made to compare test logs
** It is possible to filter log files if just the tests with specific results are needed
** The fact that the filtered logs are obtained only from the postprocessing phase guarantees that no differences caused by incompatibilities in testing code can occur
* Issues are used to signal special handling of the test. They are handled by the environment as flags excluding the marked test from processing. Only if all flags used are in the set of acceptable flags, the specific test is processed by the environment, otherwise it is skipped.
* Every test has to be in (properly matched) square brackets.
* A test is successful only if it can be correctly loaded and it yields TRUE when evaluated. While this looks like a limitation, actually it allows any kind of checks (approximate equality of some result to some predetermined value, strict equality of some result to some predetermined value, sameness of certain examined values, or any other condition that can be written in Rebol).
* Breaks, throws, errors, returns, return/redo's, etc. leading out of the test code are detected and marked as test failures.
* The test environment counts successful tests, failed tests, crashing tests, skipped tests and test dialect failures, i.e., the cases when the test file is not properly formatted.
* Files or URLs in the test file "outside" of tests are handled as directives for the test environment to process the tests in the respective file as well.
* All "catchable" exceptions are caught, but there are code examples that cause interpreter or test environment crash. Such tests are detectable from the log file, but the processing of the test file stops since the interpreter or the environment crashed. Nevertheless, the test framework is built in such a way that it can recover from any kind of crash and finish the testing after the restart.

===Test dialect

---Test cases

Test cases have to be enclosed in properly matched square brackets

---Comments

Comments following the semicolon character until the end of the line are allowed.

---Flags

Issues are used to indicate special character of tests. For example,

	#r2only

indicates that the test is meant to be used only in R2. Flags restrict the usage of tests. If the DO-RECOVER function is called without a specific flag being mentioned in the FLAGS argument, all tests marked using that flag are ignored. For example, if the above #r2only flag is not mentioned in the FLAGS argument, no #r2only test is run. Any test may be marked by as many flags as desired.

The flags used when testing REBOL/Core are:

    ; the flag influences only the test immediately following it,
    ; if not explicitly stated otherwise
    
    #32bit
    ; the test is meant to be used only when integers are 32bit
    
    #64bit
    ; the test is meant to be used only when integers are 64bit
    
    #r2only
    ; the test is not meant to be used with the R3 interpreter
    
    #r3only
    ; the test is not meant to be used with the R2 interpreter
    
    #r3
    ; the test can work with R2 if using R2/Forward, or with R3

---Files/URLs

Files or URLs specify what to include, i.e., they allow a file to contain references to other test files.

---Example

Here are some tests cases for the closure! datatype, notice that only some of them are marked as #r3only, suggesting they are meant just for the R3 interpreter:

	; datatypes/closure.r
	[closure? closure [] ["OK"]]
	[not closure? 1]
	#r3only
	[closure! = type? closure [] ["OK"]]
	; minimum
	[closure? closure [] []]
	; literal form
	#r3only
	[closure? first [#[closure! [[] []]]]]

End of the article.
