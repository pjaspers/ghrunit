require 'helper'

class TestGhrunit < Test::Unit::TestCase

  context "parsing test file" do
    setup do
      any_ghrunit.stubs(:buffer).returns(test_output_file)
      # Not building anything
      any_ghrunit.stubs(:run_build!)
      # Not logging anything
      any_ghrunit.stubs(:log)
    end

    should "log beginning of suite" do
      any_ghrunit.expects(:log_suite).with("Tests")
      GHRunit.new
    end

    should "log all test files and methods" do
      any_ghrunit.expects(:log_test).with("TestOne", "firstTest")
      any_ghrunit.expects(:log_test).with("TestOne", "lastTest")
      any_ghrunit.expects(:log_test).with("TestTwo", "testTwoFail")
      any_ghrunit.expects(:log_test).with("TestTwo", "testTwoOK")
      GHRunit.new
    end

    should "log all test responses" do
      any_ghrunit.expects(:log_test_response).with("OK", "0.000s").at_least(3)
      any_ghrunit.expects(:log_test_response).with("FAIL", "0.000s").at_least(1)
      GHRunit.new
    end

    should "log the summary" do
      any_ghrunit.expects(:log_summary).with("Executed 2 of 2 tests, with 1 failures in 4.535 seconds (0 disabled).")
      GHRunit.new
    end
  end

  context "parsing summary" do
    setup do
      any_ghrunit.stubs(:start_suite!)
      # Not logging anything
      any_ghrunit.stubs(:log)
    end

    # should "make summary green of 0 failures" do
    #   Turn::Colorize.expects(:color_green)
    #   ghrunit = GHRunit.new
    #   ghrunit.log_summary("0 failures")
    # end

    # should "make summary red with more than 0 failures" do
    #   Turn::Colorize.expects(:red)
    #   ghrunit = GHRunit.new
    #   ghrunit.log_summary("8 failures")
    # end
  end
end
