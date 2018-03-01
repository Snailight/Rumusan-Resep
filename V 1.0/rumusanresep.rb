module RumusanResep
	def self.mulai
		@acara = acara_pertama.new
	end

	def self.acara_pertama
		MenuUtama
	end

	def self.perbarui
		PapanTik.perbarui
		Jendela.perbarui
		@acara.perbarui
	end
end