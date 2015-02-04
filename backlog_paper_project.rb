# encoding: utf-8
# backlog の論文プロジェクトと課題のテンプレをinitする
# ruby backlog_auto.rb プロジェクト名 プロジェクトキー テンプレCSV

require 'net/http'
require 'uri'
require "json"
require 'CSV'


# BacklogのエンドポイントとAPIKey
# APIKeyは個人垢紐付けと思われる
$url = "http://133.30.159.201/backlog/api/v2/"
$apikey = "?apiKey=g4rZR1IIo3F2HYqk00FV5wgL7mP3mLmsx9fWrhXcH4tAoVOFOkr86BMo4RBwig3K"


# 第一引数を名前、第二引数をプロジェクトキーとしたプロジェクトの作成
# projectの作成はPOSTで行う必要がある
# 返り値: 作成したプロジェクトのID
def create_project(name, key)
  res = Net::HTTP.post_form(URI.parse($url + "projects" + $apikey),
  {'name' => name, 'key' => key, 'chartEnabled' => true, 'subtaskingEnabled' => true, 'textFormattingRule' => 'backlog'})
  json = JSON.parser.new(res.body).parse()
  return json['id']
end

# 引数: 作成したプロジェクトのID
# 指定したCSVから課題のテンプレを作成する
def init_project(projectid, cid)
#  CSV.foreach('temp.csv') do |row|
  CSV.foreach(ARGV[2]) do |row|
    # 件名,詳細,開始日,期限日,予定時間,実績時間,種別名,カテゴリ名,発生バージョン名,マイルストーン名,優先度ID,担当者ユーザ名,親課題
    res = Net::HTTP.post_form(URI.parse($url + "issues" + $apikey),
 {'projectId' => projectid, 'summary' => row[0], 'description' => row[1], 'startDate' => row[2], 'dueDate' => row[3], 'estimatedHours' => row[4], 'actualHours' => row[5], 'issueTypeId' => 0,
#'category' => [row[7]], 'version' => [row[8]], 'milestoneId' => [row[9]],
'categoryId' => nil, 'version' => [row[8]], #'milestoneId' => ,
'priorityId' => row[10], 'notifiedUserId' => [row[11]], 'parentIssueId' => row[12]})
    p res.body
  end
end

# バージョン/マイルストーンの作成
def create_version(projectid)
  Net::HTTP.post_form(URI.parse($url + "projects/" + projectid.to_s + "/versions" + $apikey),
  {'name' => '論文'})
  Net::HTTP.post_form(URI.parse($url + "projects/" + projectid.to_s + "/versions" + $apikey),
  {'name' => '発表'})
end

# カテゴリの作成
def create_category(projectid)
    res = Net::HTTP.post_form(URI.parse($url + "projects/" + projectid.to_s + "/categories" + $apikey),
    {'name' => '研究会'})
    json = JSON.parser.new(res.body).parse()
    return json['id']
end

# main
id = create_project(ARGV[0], ARGV[1])
create_version(id)
categoryid = create_category(id)
p categoryid
init_project(id, categoryid)
