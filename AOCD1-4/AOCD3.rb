require 'set'
require 'pry'

class Fabric
  attr_reader :fabric, :shared_sqrs, :sqr_data

  def initialize
    @fabric = []
    @shared_sqrs = Set.new
    @sqr_data = {}
  end

  def gen_sqr_id(row, col)
    "#{row},#{col}"
  end

  def row(i)
    @fabric[i].is_a?(Array) ? @fabric[i] : @fabric[i] = []
  end

  def col(row, i)
    row(row)[i].is_a?(Array) ? row(row)[i] : row(row)[i] = []
  end

  def claim_sqr(row, col, claim_id)
    sqr = col(row, col)
    sqr_id = gen_sqr_id(row, col)

    add_sqr_data(sqr_id, claim_id)

    if already_claimed?(sqr)
      @shared_sqrs.add(sqr_id)
    end

    sqr << claim_id
  end

  def already_claimed?(sqr)
    sqr.length > 0
  end

  def add_sqr_data(sqr_id, claim_id)
    if (@sqr_data[sqr_id])
      @sqr_data[sqr_id].add(claim_id)
    else
      @sqr_data[sqr_id] = Set.new([claim_id])
    end
  end
end

def claims
  @claims ||= read_input
end

def read_input
  input ||= []
  File.foreach('fabric_claims.txt') do |claim|
    input << parse_claim(claim)
  end
  input
end

def parse_claim(claim)
  id = claim.split('#').last.split('@').first.to_i
  dim = claim.split(':').last.split('x').map(&:to_i)
  pos = claim.split('@').last.split(':').first.split(',').map(&:to_i).reverse #[row, col]
  [id, dim, pos]
end


def fabric
  @fabric ||= Fabric.new
end

def apply_claims
  #1 @ 1,3: 4x4
  claims.each do |claim|
    id = claim[0]

    dim = claim[1]
    width = dim.first
    height = dim.last

    pos = claim[2]
    start_row = pos.first
    start_col = pos.last

    height.times do |h|
      width.times do |w|
        fabric.claim_sqr(start_row + h, start_col + w, id)
      end
    end
  end
end

def compute_non_overlapping_claim
  apply_claims

  black_list = Set.new
  white_list = Set.new

  fabric.sqr_data.values.each do |claim_ids_set|
    if claim_ids_set.length > 1
      add_to_black_list_remove_from_white_list(black_list,white_list, claim_ids_set )
    elsif claim_ids_set.length == 1 && !black_listed?(black_list, claim_ids_set)
      add_to_white_list(white_list, claim_ids_set)
    end
  end

  white_list.inspect # 1019 √
end

def black_listed?(black_list, claim_ids_set)
  claim_ids_set.any?{ |id| black_list.include?(id) }
end

def add_to_black_list_remove_from_white_list(black_list, white_list, claim_ids_set)
  claim_ids_set.each do |id|
    black_list.add(id)
    white_list.delete(id)
  end
end

def add_to_white_list(white_list, claim_ids_set)
   claim_ids_set.each { |id| white_list.add(id) }
end

puts compute_non_overlapping_claim

