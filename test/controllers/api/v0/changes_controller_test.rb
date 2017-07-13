require 'test_helper'

class Api::V0::ChangesControllerTest < ActionDispatch::IntegrationTest
  test 'can list changes' do
    page = pages(:home_page)
    get(api_v0_page_changes_path(page))

    assert_response :success
    assert_equal 'application/json', @response.content_type
    body = JSON.parse @response.body
    assert body.key?('links'), 'Response should have a "links" property'
    assert body.key?('data'), 'Response should have a "data" property'
    assert(body['data'].is_a?(Array), 'Data should be an array')
  end

  test 'can get a single change by version IDs' do
    page = pages(:home_page)
    from_version = versions(:page1_v1)
    to_version = versions(:page1_v2)
    get(api_v0_page_change_path(page, "#{from_version.id}..#{to_version.id}"))

    assert_response :success
    assert_equal 'application/json', @response.content_type
    body = JSON.parse @response.body
    assert body.key?('links'), 'Response should have a "links" property'
    assert body.key?('data'), 'Response should have a "data" property'
    assert_equal(from_version.id, body['data']['uuid_from'], 'Response has wrong "from" version')
    assert_equal(to_version.id, body['data']['uuid_to'], 'Response has wrong "to" version')
  end

  test 'can filter by priority' do
    page = pages(:home_page)

    get(api_v0_page_changes_path(page, priority_gt: 0.5))
    assert_response :success
    body = JSON.parse @response.body
    assert(body['data'].length.positive?, 'Did not get any changes back')
    body['data'].each do |change|
      priority = change['priority']
      assert(priority > 0.5, "Got a priority not > 0.5: #{priority} (from #{change['uuid']})")
    end

    get(api_v0_page_changes_path(page, priority_gte: 0.75))
    assert_response :success
    body = JSON.parse @response.body
    assert(body['data'].length.positive?, 'Did not get any changes back')
    body['data'].each do |change|
      priority = change['priority']
      assert(priority >= 0.75, "Got a priority not >= 0.75: #{priority} (from #{change['uuid']})")
    end

    get(api_v0_page_changes_path(page, priority_lt: 0.75))
    assert_response :success
    body = JSON.parse @response.body
    assert(body['data'].length.positive?, 'Did not get any changes back')
    body['data'].each do |change|
      priority = change['priority']
      assert(priority < 0.75, "Got a priority not < 0.5: #{priority} (from #{change['uuid']})")
    end

    get(api_v0_page_changes_path(page, priority_lte: 0.5))
    assert_response :success
    body = JSON.parse @response.body
    assert(body['data'].length.positive?, 'Did not get any changes back')
    body['data'].each do |change|
      priority = change['priority']
      assert(priority <= 0.5, "Got a priority not <= 0.5: #{priority} (from #{change['uuid']})")
    end
  end
end
