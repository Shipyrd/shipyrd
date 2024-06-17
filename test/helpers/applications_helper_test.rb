require "test_helper"

class ApplicationsHelperTest < ActionView::TestCase
  describe "application_status_color" do
    it "returns grey for pre-connect" do
      assert_equal "grey", application_status_color("pre-connect")
    end
  end

  describe "display_commit_message" do
    setup do
      @application = create(:application)
    end

    it "returns nil if commit message is blank" do
      assert_nil display_commit_message(nil, @application)
    end

    it "returns the commit message if blank or unsupported repository url" do
      assert_equal "Changed this thing #22, #43", display_commit_message("Changed this thing #22, #43", @application)

      @application.update!(repository_url: "https://gitlab.com/u/r")
      assert_equal "Changed this thing #22", display_commit_message("Changed this thing #22", @application)
    end

    it "links to all issues if github repository URL is set" do
      @application.update!(repository_url: "https://github.com/u/r")
      issues_url = "#{@application.repository_url}/issues"

      assert_equal(
        "Fixed: <a href='#{issues_url}/22'>#22</a>, <a href='#{issues_url}/34'>#34</a>",
        display_commit_message("Fixed: #22, #34", @application)
      )
    end
  end
end
