Jendela = JendelaAplikasi.new("Rumusan Resep", 500, 500) do |aturan|
	aturan[:X] = 400
	aturan[:Y] = 100
end

class Kanvas
	alias initialize_asli initialize
	def initialize(x, y, w, h)
		initialize_asli(Jendela, x, y, w, h)
	end
end

Dir.glob(File.join("**", "*.rb")) do |file|
	next if File.expand_path(file) == __FILE__
	load file
end

RumusanResep.mulai
RumusanResep.perbarui while true