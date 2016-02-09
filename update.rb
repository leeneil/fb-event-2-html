# encoding=utf-8 
require 'open-uri'
require 'json'
require 'date'
require 'time'
# require './utc2local'
# require './fb2wp'
# require 'to_xml'

get_pic = true

if ARGV.length > 0
	lim = ARGV[0].to_i
else
	lim = 1
end

page_id = '1519381238362637'
# token = 'CAACEdEose0cBAL7ZAFaYGYt6WEDlSdgolMUG3EJZCA1Oa5SZBsdBso8ZCT7aFBQWYMmpgcpAH28624POqmbvaTDZBdHG9GeAKmDRejoQ68IoyWbz4OVB5WyBvRJDw4r3mZBjD2UELM6BmkZCRJWxUUZCzZBXbW4EXZCtZAzPUcKSd8fbozdjq9ctswucFJtMClPovRmIyGJTgKFwAF5KJjy9yNE'
token = STDIN.read

if lim < 250
	url = 'https://graph.facebook.com/v2.5/' + page_id + '/photos/?fields=id,name,likes.limit(100)&limit=' + lim.to_s
else
	url = 'https://graph.facebook.com/v2.5/' + page_id + '/photos/?fields=id,name,likes.limit(100)&limit=250'
end

url = url + '&access_token=' + token

puts url

json = open(url)

puts "get first json"

data_hash = JSON.parse(json.read)
# xml_hash = {"channel"=>{"item"=>[]}}

count = 0


data_hash["data"].each do |datum|
	# puts datum["id"]

	if datum["name"].nil?
		# photo_url = 'https://graph.facebook.com/v2.5/' + datum["id"]
		# photo_url = photo_url + '?fields=name&access_token=' + token
		# photo_json = open(photo_url)
		# photo_hash = JSON.parse(photo_json.read)
		# puts photo_hash
		datum["name"] = "無題"
	end

	if datum["likes"].nil?
		datum["like"] = 0
	else
		datum["like"] = datum["likes"]["data"].length
	end

	puts datum["name"]
	puts "likes = " + datum["like"].to_s


	obj_url = "https://graph.facebook.com/v2.5/" + datum["id"] + "/picture"
	obj_url = obj_url + '?access_token=' + token

	# puts obj_url

	photo = open(obj_url)
	# puts json.read
	# obj_hash = JSON.parse(json.read)


	# puts obj_hash["url"]


	# get picture
	if get_pic
		if File.exist?("pics_archive/" + datum["id"]+".jpg")
			puts "pic skipped"
		else
			open("pics_archive/" + datum["id"]+".jpg", 'wb') do |file|
				file << photo.read
			end
			puts "pic downloaded"
		end
	end


	count = count + 1
	if count >= lim
		break
	end

	# puts post_hash
end

puts "counts = " + count.to_s


# sorting
sorted_posts = data_hash["data"].sort_by { |k| k["like"] }.reverse


# generate html file
open("index.html", 'wb') do |file|
	open("html_template1.txt", 'r') do |tmp|
		file << tmp.read
	end
	file << '<div class=\"row\">'
	sorted_posts.each do |datum|
		img_tag = '<a href="https://www.facebook.com/photo.php?fbid=' \
		+ datum["id"] + '" target="_blank">'\
		+ "<img src=\"" \
		+ "pics_archive/" + datum["id"] + ".jpg" \
		+ "\" alt=\"" \
		+ datum["name"] \
		+ '" class=\"img-thumbnail">' \
		+ '</a>'
		file << "<div class=\"col-sm-6 col-md-4\"><div class=\"thumbnail\">"
		file << img_tag
		file << "<div class=\"caption\">"
		file << "<h3>" + datum["name"] + "</h3>"
		file << "</div></div></div>"
	end
	file << "</div>"

	open("html_template2.txt", 'r') do |tmp|
		file << tmp.read
	end
end



