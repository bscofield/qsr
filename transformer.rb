require 'json'
require 'csv'
require 'pp'

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

d_rating = {'1' => 0, '2' => 0, '3' => 0, '4' => 0, '5' => 0}

count_by_day = data.inject({}) do |hash, book|
  hash[book[:date_read]] ||= {fiction: d_rating.dup, nonfiction: d_rating.dup}
  rating = book[:rating].to_s
  cat = book[:category].sub('-', '').to_sym

  hash[book[:date_read]][cat][rating] = hash[book[:date_read]][cat][rating] + 1
  hash
end

fr1, fr2, fr3, fr4, fr5, nr1, nr2, nr3, nr4, nr5 = [], [], [], [], [], [], [], [], [], []
count_by_day.each do |day, counts|
  fic_count = counts[:fiction].inject(0) do |sum,x|
    sum = sum + x[1]
    sum
  end
  nonfic_count = counts[:nonfiction].inject(0) do |sum,x|
    sum = sum + x[1]
    sum
  end

  fr1 << {x: day, rating: 1, category: 'fiction', y: counts[:fiction]['1']}
  fr2 << {x: day, rating: 2, category: 'fiction', y: counts[:fiction]['2']}
  fr3 << {x: day, rating: 3, category: 'fiction', y: counts[:fiction]['3']}
  fr4 << {x: day, rating: 4, category: 'fiction', y: counts[:fiction]['4']}
  fr5 << {x: day, rating: 5, category: 'fiction', y: counts[:fiction]['5']}

  nr1 << {x: day, rating: 1, category: 'nonfiction', y: counts[:nonfiction]['1']}
  nr2 << {x: day, rating: 2, category: 'nonfiction', y: counts[:nonfiction]['2']}
  nr3 << {x: day, rating: 3, category: 'nonfiction', y: counts[:nonfiction]['3']}
  nr4 << {x: day, rating: 4, category: 'nonfiction', y: counts[:nonfiction]['4']}
  nr5 << {x: day, rating: 5, category: 'nonfiction', y: counts[:nonfiction]['5']}
end

File.open('data/timeline.json', 'w') do |f|
  d = {
    ratings: [fr1, fr2, fr3, fr4, fr5, nr1, nr2, nr3, nr4, nr5]
  }.to_json
  f.puts d
end

category_rating = data.inject({}) do |hash,book|
  cat = book[:category].sub('-', '').to_sym
  hash[cat] ||= {'1' => 0, '2' => 0, '3' => 0, '4' => 0, '5' => 0}
  hash[cat][book[:rating]] = hash[cat][book[:rating]] + 1
  hash
end

fiction = category_rating[:fiction].keys.sort.map {|k|
  {x: k, rating: k, y: category_rating[:fiction][k], category: 'fiction'}
}
nonfiction = category_rating[:nonfiction].keys.sort.map {|k|
  {x: k, rating: k, y: category_rating[:nonfiction][k], category: 'nonfiction'}
}

File.open('data/ratings.json', 'w') do |f|
  f.puts (fiction + nonfiction).to_json
end
