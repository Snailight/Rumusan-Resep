module XML
	def self.ke_xml(bentuk)
		return buat_bentuk_penyimpanan(bentuk)
	end

	class << self
		def buat_bentuk_penyimpanan(resep)
			return "<data_tersimpan/>" if resep.empty?
			data_simpan = "<data_tersimpan>\n\n</data_tersimpan>"
			resep.each do |r|
				indeks = data_simpan =~ /\<\/data_tersimpan\>/
				data_simpan.insert(indeks, bentuk_xml_resep(r) + "\n" * 2)
			end
			return JENIS_XML + data_simpan
		end

		def header_resep(nama, banyak, kosong=false)
			if kosong
				sprintf("#{PARAGRAF_RESEP}<resep nama=\"%s\" bahan=\"%d\" />", nama, banyak)
			else
				sprintf("#{PARAGRAF_RESEP}<resep nama=\"%s\" bahan=\"%d\" >\n</resep>", nama, banyak)
			end
		end

		def bentuk_xml_resep(resep)
			nama = resep.nama
			return header_resep(nama, 0, true) if resep.bahan.empty?
			bentuk = header_resep(nama, resep.bahan.size)
			resep.bahan.each do |k, v|
				indeks = bentuk =~ /\<\/resep\>/
				bentuk.insert(indeks, sprintf("%s%s\n", PARAGRAF_BAHAN, bentuk_xml_bahan(k, v)))
			end
			bentuk.insert(bentuk =~ /\<\/resep\>/, PARAGRAF_RESEP)
			return bentuk
		end

		def bentuk_xml_bahan(nama, banyak)
			sprintf("<bahan nama=\"%s\" banyak=\"%d\" />", nama, banyak)
		end
	end
end