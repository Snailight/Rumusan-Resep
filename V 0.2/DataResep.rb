module DataResep
	@daftar_resep = File.exist?("daftar_resep.xml") ? XML.baca(File.read("daftar_resep.xml")) || [] : []

	Tambah_Bahan = "++ Tambah Bahan ++"

	Resep_Maksimum = 375
	Bahan = begin
		eval(File.read("bahan.txt"))
	rescue SyntaxError, Errno::ENOENT, NameError
		File.write("bahan.txt", "[]")
		retry
	end

	class << self
		def resep(indeks)
			@daftar_resep[indeks]
		end

		def semua_resep
			@daftar_resep
		end

		def tambah(resep)
			@daftar_resep << resep
		end

		def hapus(indeks)
			@daftar_resep.delete_at(indeks)
		end

		def banyak
			@daftar_resep.size
		end
	end

	VERSI = "0.2 Beta"
	COPYRIGHT = "2018 Snailight"
	TANGGAL = ["14 Januari 2018", "09 : 10"]


	PENGHORMATAN = "Terimakasih telah mencoba aplikasi kami"
	PESAN_PEMBUAT = ["Dibuat di Indonesia, Dilarang di mengkomersialkan", "software dalam bentuk apapun"]
	KONTAK = "Facebook : Reckordp"
end