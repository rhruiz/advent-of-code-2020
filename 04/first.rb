require 'set'

REQUIRED = Set.new(%w[byr iyr eyr hgt hcl ecl pid cid])

passports = File
  .open("input.txt")
  .read
  .split(/\n\n/)
  .map do |line|
    line
      .strip
      .split(/[\n ]/)
      .map { |field| field.split(":") }
      .to_h
  end

def valid?(passport)
  keys = passport.dup
  keys.delete("cid")
  keys = keys.keys
  Set.new(keys) == REQUIRED.delete("cid")
end

puts passports.select(&method(:valid?)).count
