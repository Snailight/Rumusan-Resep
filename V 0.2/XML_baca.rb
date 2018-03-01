module XML
	def self.baca(file)
		return unless file.is_a?(String)
		daftar_resep = []
		return nil unless file =~ /\<data_tersimpan\>([#{REGEXP_DITERIMA_DAFTAR}]+)\<\/data_tersimpan\>/
		tangkap = $1.clone.split(/[\n\t]+/)

		begin
			resep = nil
			bahan = {}
			tangkap.each do |baris|
				case baris
				when REGEXP_DITERIMA_RESEP
					resep = Resep.new($1)
				when REGEXP_DITERIMA_RESEP_KOSONG
					daftar_resep << Resep.new($1)
				when REGEXP_DITERIMA_BAHAN
					bahan[$1] = $2.to_i
				when REGEXP_DITERIMA_AKHIR_RESEP
					resep.bahan = bahan.clone
					daftar_resep << resep.clone
					bahan.clear
					resep = nil
				end
			end
		rescue Exception
			return nil
		end

		return daftar_resep
	end
	
end
