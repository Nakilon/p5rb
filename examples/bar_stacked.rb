unless File.exist?("temp.json") && 20967 == File.read("temp.json").sum
  require "open-uri"
  File.write "temp.json", open("https://storage.yandexcloud.net/gems.nakilon.pro/p5rb/ChatExport_2022-12-09_danya.json", &:read)
end
require "json"
all = JSON.load File.read "temp.json"

require "date"
users = {}

require_relative "../lib/p5rb"
puts P5.plot_bar_stacked(
  all["messages"].map do |msg|
    next unless "message" == msg["type"]
    users[msg["from_id"]] = msg["from"]
    [Date.parse(msg["date"]), msg["from_id"], msg["text"]]
  end.compact.group_by{ |_,| _.jd/7 }.map do |jw, g|
    [
      g.map(&:first).minmax.map{ |_| _.strftime "%m-%d" }.join(" - "),
      g.group_by{ |_,id,| id }.map{ |id, g| [id, g.size] }
    ]
  end,
  users,
  30
)
