ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

require 'active_support_test_unit_pass_count'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Asserts that an attribute cannot be null in db.
  def assert_not_null_in_db(class_name, some_valid_attributes, attribute)
    instance = class_name.new(some_valid_attributes)

    instance[attribute] = nil
    assert_raises ActiveRecord::StatementInvalid, "You expected an exception of StatementInvalid when saving attribute: #{attribute}" do
      instance.save!(:validate => false)
    end
  end

  def assert_many_not_null_in_db(class_name, some_valid_attributes, attributes_array)
    attributes_array.each do |attribute_name|
      assert_not_null_in_db(class_name, some_valid_attributes, attribute_name)
    end
  end

  # It checks that the attribute +attribute+ of the model +class_name+
  # is limited in storage by the value +length+
  def assert_length_in_db(class_name, some_valid_attributes, attribute, length, destroy=false)
    instance = class_name.new(some_valid_attributes)

    instance[attribute] = 'a' * (length + 1)
    assert_raises ActiveRecord::StatementInvalid, "<#{class_name}>.<#{attribute}> with length #{length} seems to be ok" do
      instance.save!(:validate => false)
    end

    instance[attribute] = 'a' * length
    assert instance.save!(:validate => false)

    instance.destroy if destroy
  end

  def assert_many_lengths_in_db(class_name, some_valid_attributes, attributes_lengths_hash)

    attributes_lengths_hash.each do |attribute_name, length|
      assert_length_in_db(class_name, some_valid_attributes, attribute_name, length, true)
    end

  end

  # It checks that the attribute +attribute+ of the model +class_name+
  # is limited in length by the value +length+
  def assert_length_in_model(class_name, some_valid_attributes, attribute, length)
    instance = class_name.new(some_valid_attributes)

    instance[attribute] = 'a' * (length + 1)
    assert instance.invalid?, "#{attribute} can be longer than #{length}"
    assert instance.errors[attribute].length >= 1

    instance[attribute] = 'a' * length
    assert instance.valid?, "#{attribute} does not have the #{length} as validation length in model"
  end

  def assert_many_lengths_in_model(class_name, some_valid_attributes, attributes_lengths_hash)
    attributes_lengths_hash.each do |attribute_name, length|
      assert_length_in_model(class_name, some_valid_attributes, attribute_name, length)
    end
  end

  # It checks that the attribute +attribute+ of the model +class_name+
  # is limited in length by the value +length+. If a longer value is given
  # this is truncated and model is considered valid.
  def assert_length_with_truncate_in_model(class_name, some_valid_attributes, attribute, length)
    instance = class_name.new(some_valid_attributes)

    instance.send("#{attribute}=", "")

    value_to_assign = 'a' * (length + 1)
    value_that_is_saved = value_to_assign.mb_chars.slice(0, length)
    instance[attribute] = value_to_assign

    assert instance.valid?
    assert_equal value_that_is_saved, instance[attribute]
  end

  def assert_many_lengths_with_truncate_in_model(class_name, some_valid_attributes, attributes_lengths_hash)
    attributes_lengths_hash.each do |attribute_name, length|
      assert_length_with_truncate_in_model(class_name, some_valid_attributes, attribute_name, length)
    end
  end

  def assert_presence_of_attribute(class_name, some_valid_attributes, attribute)
    # make sure that attribute exists in some valid attributes and it is not nil or blank
    assert some_valid_attributes[attribute].present?, "#{attribute} needs to be initially present in order for test to run"

    instance = class_name.new(some_valid_attributes)

    instance[attribute] = nil
    assert_invalid(instance)
    assert instance.errors[attribute].length >= 1
  end

  def assert_presence_of_many_attributes(class_name, some_valid_attributes, attributes_array)
    attributes_array.each do |attribute_name|
      assert_presence_of_attribute(class_name, some_valid_attributes, attribute_name)
    end
  end

  # Asserts that the given ++ActiveModel++ is "invalid".
  # The ++attributes_with_errors++ options should a hash of attributes to be specifically
  # examined for having errors. For example : {:email => 1, :username => 2} (etc).
  #
  def assert_invalid(object, attributes_with_errors = {})
    assert object.invalid?, "Expected #{object} to be invalid, but was actually valid"

    attributes_with_errors.each do |attribute, expected_number_of_errors|
      actual_errors_on_attribute = object.errors[attribute].length
      error_message = "Expected #{expected_number_of_errors} errors on #{attribute}, but were actually #{actual_errors_on_attribute} : \n"
      error_message << "#{object.errors[attribute].join("\n")}"
      assert_equal expected_number_of_errors, actual_errors_on_attribute, error_message
    end
  end

  # Asserts that the given ++ActiveModel++ is "valid".
  # If not, the error message is the full error messages.
  #
  def assert_valid(object, additional_message = nil)
    is_valid = object.valid?
    error_message = additional_message ? "#{additional_message}\n#{object.errors.full_messages}" : object.errors.full_messages.join("\n")
    assert is_valid, error_message
  end

  def assert_invalid_attribute(object, attribute, error_message = nil)
    object.valid?
    is_attribute_with_errors = object.errors[attribute].present?
    assert is_attribute_with_errors, error_message ? error_message : "#{attribute} is valid"
  end

  def assert_valid_attribute(object, attribute, error_message = nil)
    object.valid?
    is_attribute_with_errors = object.errors[attribute].present?
    assert !is_attribute_with_errors, error_message ? error_message : "#{attribute} is invalid"
  end

  # Asserts that an attribute can be null in db.
  def assert_null_in_db(class_name, some_valid_attributes, attribute, destroy=false)
    instance = class_name.new(some_valid_attributes)

    instance[attribute] = nil
    assert instance.save(:validate => false)
    # I delete this in order to be able to call this method from within assert_many...
    instance.destroy if destroy
  end

  def assert_many_null_in_db(class_name, some_valid_attributes, attributes_array)
    attributes_array.each do |attribute_name|
      assert_null_in_db(class_name, some_valid_attributes, attribute_name, true)
    end
  end

  def assert_many_default_value_in_db(class_to_instantiate, hash_of_valid_attributes, attributes_to_test, default_value)
    attributes_to_test.each do |a|
      assert_default_value_in_db(class_to_instantiate, hash_of_valid_attributes, a, default_value)
    end
  end

  def assert_default_value_in_db(class_to_instantiate, hash_of_valid_attributes, attribute_to_test, default_value)
    an_instance = class_to_instantiate.new(hash_of_valid_attributes)
    an_instance.save(:validate => false)
    an_instance.reload
    assert_equal default_value, an_instance.send("#{attribute_to_test}")
    an_instance.destroy # we destroy in order to allow this method to be called in a loop
  end

  def assert_many_integer_attribute_greater_than_or_equal_to_zero_and_blank_is_allowed(class_to_instantiate, hash_with_valid_attributes, attributes)
    attributes.each do |a|
      assert_integer_attribute_greater_than_or_equal_to_zero_and_blank_is_allowed(class_to_instantiate, hash_with_valid_attributes, a)
    end
  end

  def assert_integer_attribute_greater_than_or_equal_to_zero_and_blank_is_allowed(class_to_instantiate, hash_with_valid_attributes, attribute)
    an_instance = class_to_instantiate.new(hash_with_valid_attributes)
    # invalid cases
    [-1, -0.99, 0.5, 1.2, 3.5].each do |v|
      an_instance.send("#{attribute}=", v)
      assert_invalid an_instance, {attribute => 1}
    end
    # valid cases
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10000, 100000, 200000, 3000000, 1000000000].each do |v|
      an_instance.send("#{attribute}=", v)
      assert_valid an_instance
    end
    # blank is allowed
    an_instance.send("#{attribute}=", nil)
    assert_valid an_instance
  end

  def assert_boolean_attribute(klass, valid_attributes, attribute, allow_blank=true)
    instance = klass.new(valid_attributes)

    assert instance.valid?
    instance[attribute] = nil
    if allow_blank
      assert instance.valid?, "#{attribute} with value nil makes object invalid"
    else
      assert instance.invalid?, "#{attribute} with value nil does not make object invalid"
      assert instance.errors[attribute].length >= 1, "#{attribute} with value #{instance[attribute]} does not give any errors on this attribute"
    end

    [true, false].each do |v|
      instance.send("#{attribute}=", v)
      assert instance.valid?, "#{attribute} with value #{v} does not render object valid"
    end
  end

  def assert_many_boolean_attributes(klass, valid_attributes, attributes_array, allow_blank=true)
    attributes_array.each do |attribute_name|
      assert_boolean_attribute(klass, valid_attributes, attribute_name, allow_blank)
    end
  end

  # Asserts that the controller assigned an instance variable with the given +instance_variable_name+
  # and optionally checks that it's 'is equal with the given +expected_value+.
  def assert_assigns(instance_variable_name, expected_value = nil)
    assert_not_nil assigns(instance_variable_name), "#{instance_variable_name} was not assigned."
    unless expected_value.nil?
      assert_equal expected_value, assigns(instance_variable_name)
    end
  end

  def assert_many_absent_in_model(klass, valid_attributes, attributes_to_test)
    attributes_to_test.each do |a|
      an_instance = klass.new(valid_attributes)
      an_instance.send("#{a}=", nil)
      assert_valid an_instance
    end
  end

  def login_as(user)
    session[:user_id] = user.id
  end

  def logout
    session.delete :user_id
  end

end
