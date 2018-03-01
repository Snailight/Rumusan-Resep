class Resep
	attr_accessor :nama, :bahan
	def initialize(nama = "", bahan = {})
		unless nama.is_a?(String) && bahan.is_a?(Hash)
			nama = ""
			bahan = {}
		end
		@nama = nama
		@bahan = bahan
	end
end

load "XML.rb"
load "DataResep.rb"
load "JendelaResep.rb"
load "DaftarResep.rb"
load "DaftarBahan.rb"
load "Menu.rb"
load "TampilanResep.rb"

JendelaResep.new