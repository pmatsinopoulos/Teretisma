require 'test_helper'

class PostTest < ActiveSupport::TestCase

  ATTRIBUTES_MAXIMUM_LENGTHS_IN_DB    = {:title => 140}.with_indifferent_access
  ATTRIBUTES_MAXIMUM_LENGTHS_IN_MODEL = {:title => 140}.with_indifferent_access

  setup do
    @valid_attributes = {:user_id => users(:petros).id, :title => "This is my post"}.with_indifferent_access
  end

  # DB level tests

  test "some attributes cannot be null in db" do
    attributes_to_test = [:user_id, :title]
    assert_many_not_null_in_db(Post, @valid_attributes, attributes_to_test)
  end

  test "some attributes have limit in db" do
    assert_many_lengths_in_db(Post, @valid_attributes, ATTRIBUTES_MAXIMUM_LENGTHS_IN_DB)
  end

  test "posts have foreign key to users" do
    a_post = Post.new(@valid_attributes)
    a_post.user_id = -1
    assert_raises ActiveRecord::InvalidForeignKey do
      begin
        a_post.save!(:validate => false)
      rescue Exception => ex
        assert ex.message.include?("posts_users_fk")
        raise ex
      end
    end
  end

  # Model level tests

  test "a post belongs to a user" do
    assert Post.new.respond_to?(:user)
  end

  test "some attributes need to be present in model" do
    attributes_to_test = [:user_id, :title]
    assert_presence_of_many_attributes(Post, @valid_attributes, attributes_to_test)
  end

  test "some attributes have maximum length in model" do
    assert_many_lengths_in_model(Post, @valid_attributes, ATTRIBUTES_MAXIMUM_LENGTHS_IN_MODEL)
  end

  # test class methods

  test "feed index all" do
    posts = Post.feed_index_all
    [:id, :user_id, :full_name, :title, :created_at].each do |m|
      assert posts.all? { |p| p.respond_to?(m) }
    end

    # check the number of posts
    number_of_all_posts = Post.all.length
    assert number_of_all_posts > 2

    # now check the limit
    posts = Post.feed_index_all(2)
    assert_equal 2, posts.length

    # check the order by
      # delete existing
    Post.destroy_all
      # create two with 1 second time difference
    Post.create(:user_id => users(:petros).id, :title => 'title 1')
    sleep(1)
    Post.create(:user_id => users(:petros).id, :title => 'title 2')
      # retrieve and assert
    posts_ordered_by = Post.order('created_at desc').all.map{ |p| p.created_at }
    posts = Post.feed_index_all.all.map{ |p| p.created_at }
    assert_equal posts_ordered_by, posts
  end

  test "index all" do
    # check the number of posts
    number_of_all_posts = Post.all.length
    assert number_of_all_posts > 2

    # now check the limit
    posts = Post.index_all(2)
    assert_equal 2, posts.length

    # check the order by
      # delete existing
    Post.destroy_all
      # create two with 1 second time difference
    Post.create(:user_id => users(:petros).id, :title => 'title 1')
    sleep(1)
    Post.create(:user_id => users(:petros).id, :title => 'title 2')
      # retrieve and assert
    posts_ordered_by = Post.order('created_at desc').all.map{ |p| p.created_at }
    posts = Post.index_all.all.map{ |p| p.created_at }
    assert_equal posts_ordered_by, posts
  end

end
