require 'test_helper'

class UserTest < ActiveSupport::TestCase

  ATTRIBUTES_MAXIMUM_LENGTHS_IN_DB    = {:username => 12, :full_name => 30, :phone => 20}.with_indifferent_access
  ATTRIBUTES_MAXIMUM_LENGTHS_IN_MODEL = {:username => 12, :full_name => 30, :phone => 20}.with_indifferent_access

  setup do
    @valid_attributes = {
      :username => 'takis',
      :password => 'password',
      :full_name => 'Panayotis Matsinopoulos',
      :phone => '00306972669766'}.with_indifferent_access
  end

  # DB level tests

  test "some attributes in db cannot be null" do
    attributes_to_test = [:username, :password, :full_name, :phone]
    assert_many_not_null_in_db(User, @valid_attributes, attributes_to_test)
  end

  test "some attributes have limit in db" do
    assert_many_lengths_in_db(User, @valid_attributes, ATTRIBUTES_MAXIMUM_LENGTHS_IN_DB)
  end

  test "username has unique index in db" do
    a_new_user = users(:petros).dup
    a_new_user.phone = '123456789' # make sure phone is unique, but username is not
    assert_raises ActiveRecord::RecordNotUnique do
      begin
        a_new_user.save!(:validate => false)
      rescue Exception => ex
        assert ex.message.include?("users_username_uidx")
        raise ex
      end
    end
  end

  ########## end of DB level tests #############

  # Model level tests

  test "user has many posts" do
    assert User.new.respond_to?(:posts)
  end

  test "when deleting a user its posts are deleted too" do
    user = users(:petros)
    posts_length = user.posts.length
    assert posts_length > 0
    assert_difference 'User.count', -1 do
      assert_difference 'Post.count', -posts_length do
        user.destroy
      end
    end
  end

  test "username has to have a specific format" do
    a_user = User.new(@valid_attributes)
    assert_valid a_user

    a_user.username = ''
    assert_invalid_attribute a_user, :username

    a_user.username = 'ab' # length less than 3
    assert a_user.username.length < 3
    assert_invalid_attribute a_user, :username

    a_user.username = 'abcdefghijklm' # length greater than 12
    assert a_user.username.length > 12
    assert_invalid_attribute a_user, :username

    a_user.username = 'abcd-342 3' # non alphanumeric
    assert_invalid_attribute a_user, :username

    a_user.username = 'abc' # valid length 3
    assert a_user.username.length == 3
    assert_valid_attribute a_user, :username

    a_user.username = 'abcdefghijkl' # valid length 12
    assert a_user.username.length == 12
    assert_valid_attribute a_user, :username

    a_user.username = 'abcdef0123' # valid length alphanumeric
    assert a_user.username.length >=3 && a_user.username.length <= 12
    assert_valid_attribute a_user, :username
  end

  test "username is unique" do
    user = users(:petros).dup
    assert_invalid_attribute user, :username
  end

  test "full name has to have a specific format" do
    a_user = User.new(@valid_attributes)
    assert_valid a_user

    a_user.full_name = '' # non-present full_name
    assert_invalid_attribute a_user, :full_name

    a_user.full_name = 'Mats' # invalid length less than 5
    assert a_user.full_name.length < 5
    assert_invalid_attribute a_user, :full_name

    a_user.full_name = 'Matsinopoulos Matsinopoulos Mat' # invalid length greater than 30
    assert a_user.full_name.length > 30
    assert_invalid_attribute a_user, :full_name

    a_user.full_name = ' Matsinopoulos' # does not start from letter
    assert_invalid_attribute a_user, :full_name

    a_user.full_name = 'Panayotis 2 Mats' # should not contain digits
    assert_invalid_attribute a_user, :full_name

    a_user.full_name = 'Panayotis Matsinopoulos' # valid lengths, valid content
    assert a_user.full_name.length >= 5 && a_user.full_name.length <= 30
    assert_valid_attribute a_user, :full_name

    a_user.full_name = 'Panayotis-_Matsinopoul' # valid lengths and valid content
    assert a_user.full_name.length >= 5 && a_user.full_name.length <= 30
    assert_valid_attribute a_user, :full_name
  end

  test "phone has to have a specific format" do
    a_user = User.new(@valid_attributes)
    assert_valid a_user

    a_user.phone = ''
    assert_invalid_attribute a_user, :phone # too short and invalid

    a_user.phone = '111' # too short
    assert a_user.phone.length < 7
    assert_invalid_attribute a_user, :phone

    a_user.phone = '111112345678901234567' # too long
    assert a_user.phone.length > 20
    assert_invalid_attribute a_user, :phone

    a_user.phone = '123ab67' # invalid format
    assert_invalid_attribute a_user, :phone

    a_user.phone = '123-567' # invalid format
    assert_invalid_attribute a_user, :phone

    a_user.phone = '123-456-' # invalid format
    assert_invalid_attribute a_user, :phone

    a_user.phone = '12345--' # invalid format
    assert_invalid_attribute a_user, :phone

    a_user.phone = '--12345' # invalid format
    assert_invalid_attribute a_user, :phone

    a_user.phone = 'asdlfkjasdflkj' #invalid format
    assert_invalid_attribute a_user, :phone

    a_user.phone = '123456789012'
    assert_valid_attribute a_user, :phone

    a_user.phone = '01123223489'
    assert_valid_attribute a_user, :phone
  end

  ########### end of Model level tests #########

end
