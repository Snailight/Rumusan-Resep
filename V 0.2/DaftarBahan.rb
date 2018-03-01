class Daftar_Bahan < Kanvas
	def initialize(jendela)
		super(jendela, jendela.panjang - 156, 5, 150, jendela.lebar - 40)
		@semua_bahan = PetaBit.new(panjang - 14, DataResep::Resep_Maksimum * 30)
		@atas = 0
		@cari = ""
		refresh
		self.ox = -panjang
	end

	def refresh
		buat_semua_bahan
		tampilkan_bahan
	end

	def bentuk_dasar
		warnai_area(0, 0, panjang, lebar, Warna.new(0, 255, 0))
		warnai_area(1, 1, panjang - 2, lebar - 2, Warna.new(0, 220, 0))
		warnai_area(4, 4, panjang - 8, 18, Warna.new(255, 0, 0))
		warnai_area(panjang / 2 - 40, 25, 80, 8, Warna.new(200))
		warnai_area(panjang / 2 - 40, lebar - 14, 80, 8, Warna.new(200))
		font.tebal = true
		tulis(4, 4, panjang - 8, 18, @cari.empty? ? "Daftar Bahan" : @cari, 1)
		@atas = 0 unless @cari.empty?
		font.normal
	end

	def bahan
		DataResep::Bahan.find_all { |i| i.downcase =~ /#{@cari}/ }
	end

	def buat_semua_bahan
		@semua_bahan.warnai_area(Area.new(0, 0, panjang, DataResep::Bahan.size * 30), Warna.new(0, 220, 0))

		bahan.each_with_index do |bahan, indeks|
			@semua_bahan.warnai_area(Area.new(0, indeks * 30 + 5, panjang - 14, 20), Warna.new(0, 0, 255))
			@semua_bahan.tulis(font, Area.new(3, indeks * 30 + 7, panjang - 20, 18), bahan, 0)
		end
	end

	def tampilkan_bahan
		bentuk_dasar
		petabit.jiplak(7, 35, @semua_bahan, Area.new(0, @atas, panjang - 14, lebar - 50))
	end

	def perbarui
		super
		return unless kelihatan_semua?
		cek_keyboard
		k = kursor
		jendela.resep_bahan(:kosong) if Mouse.klik? && !k
		return unless k
		ubah = false
		if k.x.between?(31, 111)
			nilai = Mouse.menekan? ? 5 : 1
			if k.y.between?(19, 27)
				@atas -= nilai unless @atas < 1
				ubah = true
			elsif k.y.between?(lebar - 19, lebar - 11)
				@atas += nilai unless @atas > (DataResep::Bahan.size - 4) * 30
				ubah = true
			end
		end

		if Mouse.klik_ganda?
			jendela.resep_bahan(bahan[(k.y - 41 + @atas) / 30])
		end
		tampilkan_bahan if ubah
	end

	def cek_keyboard
		ubah = false
		PapanTik.tombol.each do |tombol|
			case tombol
			when :hapus
				@cari.slice!(-1, 1)
			when :spasi
				@cari += " " unless @cari.empty?
			else
				@cari += tombol.to_s unless tombol.to_s.size > 1 || @cari.size > 15
			end
			ubah = true
		end
		if ubah
			refresh
		end
	end

	def muncul
		self.ox += 5
	end

	def kelihatan_semua?
		self.ox == 0
	end

	def tertutup?
		self.ox < -panjang
	end
end