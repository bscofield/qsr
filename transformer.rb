require 'json'
require 'csv'
require 'ostruct'

data = CSV.read('data/books.csv', headers: true)
data = data.select {|row| Date.parse(row['Date Read'])< Date.parse(ARGV[0] || '2014-07-01')}
data = data.inject([]) do |arr, row|
  shelves = row['Bookshelves'].split(',').map(&:strip)
  category = shelves.delete('non-fiction') || shelves.delete('fiction')
  arr << {
    title: row['Title'],
    author: row['Author'],
    rating: row['My Rating'],
    average: row['Average Rating'],
    pages: row['Number of Pages'],
    date_read: row['Date Read'],
    category: category,
    shelves: shelves
  }
  arr
end

File.open('data/books.json', 'w') do |f|
  f.puts data.to_json
end

count_by_day = data.inject({}) do |hash, book|
  hash[book[:date_read]] ||= {fiction: 0, nonfiction: 0}
  cat = book[:category].sub('-', '').to_sym

  hash[book[:date_read]][cat] = hash[book[:date_read]][cat] + 1
  hash
end

fiction, nonfiction = [], []
count_by_day.each do |day, counts|
  fiction    << {x: day, y: counts[:fiction]}
  nonfiction << {x: day, y: counts[:nonfiction]}
end

File.open('data/timeline.json', 'w') do |f|
  f.puts [fiction, nonfiction].to_json
end

category_rating = data.inject({}) do |hash,book|
  cat = book[:category].sub('-', '').to_sym
  hash[cat] ||= {'1' => 0, '2' => 0, '3' => 0, '4' => 0, '5' => 0}
  hash[cat][book[:rating]] = hash[cat][book[:rating]] + 1
  hash
end

fiction = category_rating[:fiction].keys.sort.map {|k|
  {x: k, y: category_rating[:fiction][k], category: 'fiction'}
}
nonfiction = category_rating[:nonfiction].keys.sort.map {|k|
  {x: k, y: category_rating[:nonfiction][k], category: 'nonfiction'}
}

File.open('data/ratings.json', 'w') do |f|
  f.puts (fiction + nonfiction).to_json
end
