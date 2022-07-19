#!/usr/bin/env ruby
require 'json'
require 'yaml'
require 'pry'
require 'faraday'
require 'faraday/net_http'
require 'awesome_print'
require 'fileutils'

Faraday.default_adapter = :net_http

class Leetcode
  BASE_URL = URI('https://leetcode.com/graphql')
  attr_reader :problem_url

  def initialize(args = {})
    @problem_url = args[:problem_url]
  end

  def get
    response = conn.get do |req|
      req.params['query'] = query(title_slug: title_slug)
    end

    ap response.body

    parse_response_data(response.body['data'])
  end

  private

  def conn
    Faraday.new(BASE_URL) do |f|
      f.request :json
      f.request :retry
      f.response :json, content_type: /\bjson$/
      f.adapter :net_http
    end
  end

  def title_slug
    problem_url.split('/').last
  rescue StandardError
    raise StandardError, 'Question URL is not valid'
  end

  def parse_response_data(data)
    question = data['question']

    {
      name: "#{question['questionId']}.#{title_slug}",
      topic_tags: question['topicTags'].map { |tag| "##{tag['slug']}" }.join(', '),
      description: question['content'],
      stats: JSON.parse(question['stats']).each_with_object('') do |(key, value), s|
               s << "#{key}: #{value}, "
             end,
      question_id: question['questionId'],
    }
  end

  def query(args = {})
    <<~GQL
      query questionData {
        question(titleSlug: "#{args[:title_slug]}") {
          questionId
          title
          titleSlug
          content
          difficulty
          categoryTitle
          stats
          topicTags {
            name
            slug
            translatedName
          }
          likes dislikes isLiked similarQuestions exampleTestcases
        }
      }
    GQL
  end
end

class GenerateQuestion
  attr_reader :data

  def initialize(args = {})
    @data = args[:data]
  end

  def call
    File.open('README.md', 'w') do |f|
      f.write(text)
    end
  end

  def text
    @data.each_with_object('') do |(key, value), txt|
      txt << "<b> #{key.to_s.split('_').map(&:capitalize).join(' ')} :</b> #{value}"
      txt << '<br/>'
      txt << "\n"
    end
  end
end

class ParseYml
  def initialize
    @list = YAML.load_file('list.yml')
  end

  def call
    @list.keys.each do |topic|
      topic_list(@list[topic], topic)
    end
  end

  def topic_list(list, topic)
    list.each do |item|
      @data = Leetcode.new(problem_url: item).get

      FileUtils.mkdir_p("#{topic}/#{@data[:name]}")

      Dir.chdir("#{topic}/#{@data[:name]}") do
        FileUtils.touch "#{@data[:question_id]}.rb"
        FileUtils.touch "#{@data[:question_id]}.cpp"
        GenerateQuestion.new(data: @data).call
      end
    end
  end
end

puts ParseYml.new.call
# puts stats.to_a
