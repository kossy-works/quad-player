#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "rexml/document"
require "rexml/xpath"
require "time"
require "uri"

ROOT = File.expand_path("..", __dir__)
CHANNELS_PATH = File.join(ROOT, "data", "channels.json")
OUTPUT_PATH = File.join(ROOT, "data", "latest-videos.json")
MAX_RESULTS = 10

NS = {
  "atom" => "http://www.w3.org/2005/Atom",
  "media" => "http://search.yahoo.com/mrss/",
  "yt" => "http://www.youtube.com/xml/schemas/2015"
}.freeze

def text_at(node, path)
  REXML::XPath.first(node, path, NS)&.text&.strip
end

def attr_at(node, path, name)
  REXML::XPath.first(node, path, NS)&.attributes&.[](name)
end

def fetch_text(url)
  uri = URI(url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 20) do |http|
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "quad-player-rss-fetcher/1.0"
    response = http.request(request)
    raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  end
end

def parse_feed(xml, fallback_channel_title)
  doc = REXML::Document.new(xml)
  feed_title = text_at(doc, "/atom:feed/atom:title") || fallback_channel_title

  REXML::XPath.match(doc, "/atom:feed/atom:entry", NS).first(MAX_RESULTS).map do |entry|
    video_id = text_at(entry, "yt:videoId")
    next unless video_id

    {
      id: video_id,
      title: text_at(entry, "atom:title") || "(no title)",
      channelTitle: text_at(entry, "atom:author/atom:name") || feed_title,
      published: text_at(entry, "atom:published"),
      updated: text_at(entry, "atom:updated"),
      url: attr_at(entry, "atom:link[@rel='alternate']", "href") || "https://www.youtube.com/watch?v=#{video_id}",
      thumbnail: attr_at(entry, "media:group/media:thumbnail", "url") || "https://i.ytimg.com/vi/#{video_id}/mqdefault.jpg"
    }
  end.compact
end

def load_channels
  config = JSON.parse(File.read(CHANNELS_PATH))
  config.fetch("groups").flat_map do |group|
    group.fetch("channels").map do |channel|
      {
        id: channel.fetch("id"),
        name: channel.fetch("name"),
        group: group.fetch("name")
      }
    end
  end
end

channels = load_channels
generated_at = Time.now.utc.iso8601

result_channels = channels.map do |channel|
  feed_url = "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel[:id]}"
  fetched_at = Time.now.utc.iso8601

  begin
    videos = parse_feed(fetch_text(feed_url), channel[:name])
    {
      id: channel[:id],
      name: channel[:name],
      group: channel[:group],
      feedUrl: feed_url,
      fetchedAt: fetched_at,
      status: "ok",
      videos: videos
    }
  rescue StandardError => e
    warn "#{channel[:name]} (#{channel[:id]}): #{e.message}"
    {
      id: channel[:id],
      name: channel[:name],
      group: channel[:group],
      feedUrl: feed_url,
      fetchedAt: fetched_at,
      status: "error",
      error: e.message,
      videos: []
    }
  end
end

if result_channels.none? { |channel| channel[:status] == "ok" }
  raise "All YouTube RSS fetches failed"
end

payload = {
  generatedAt: generated_at,
  source: "youtube-rss",
  channels: result_channels
}

File.write(OUTPUT_PATH, JSON.pretty_generate(payload))
puts "Wrote #{OUTPUT_PATH}"
