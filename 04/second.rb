require 'set'

REQUIRED = Set.new(%w[byr iyr eyr hgt hcl ecl pid])

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
  Set.new(keys) == REQUIRED && REQUIRED.all? { |field| valid_field?(passport, field) }
end

def valid_field?(passport, field)
  validations = {
    byr: ->(value) { value.length == 4 && (1920..2002).member?(value.to_i) },
    iyr: ->(value) { value.length == 4 && (2010..2020).member?(value.to_i) },
    eyr: ->(value) { value.length == 4 && (2020..2030).member?(value.to_i) },
    hcl: ->(value) { value =~ /\A#[0-9a-f]{6}\z/ },
    ecl: ->(value) { %w[amb blu brn gry grn hzl oth].member?(value) },
    pid: ->(value) { value =~ /\A[0-9]{9}\z/ },
    hgt: ->(value) { case value
                       when /\A(\d+)in\z/
                         (59..76).member?($1.to_i)
                       when /\A(\d+)cm\z/
                         (150..193).member?($1.to_i)
                       else
                         false
                     end}
  }

  !!validations[field.to_sym].call(passport[field])
end

puts passports.select { |p| valid?(p) }.count
