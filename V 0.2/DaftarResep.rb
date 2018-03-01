class DaftarResep
	def initialize(jendela)
		@jendela = jendela
		x = 10
		y = 10
		w = @jendela.panjang * 2 / 3
		h = @jendela.lebar - 100
		@buka = Kanvas.new(jendela, x, y + 40, w, h)
		@tutup = Kanvas.new(jendela, x, y, w, 40)
		@petabit = PetaBit.new(w, DataResep::Resep_Maksimum * 50)
		@pembukaan = false
		@kunci = false
		@atas = 0
		@pilih = -1
	end

	def isi_buka
		@buka.latar = Warna.new(190)
		@buka.font.ukuran = 30
		@buka.oy = @buka.panjang + 50
		perbarui_resep
	end

	def isi_tutup
		@tutup.latar = Warna.new(230)
		@tutup.warnai_area(@tutup.panjang - 55, 0, 45, 20, Warna.new(195))
		@tutup.tulis(@tutup.panjang - 50, 0, 50, 20, "kunci")
		@tutup.font.ukuran = 30
		@tutup.font.tebal = true
		@tutup.tulis(0, 0, @tutup.panjang - 20, 40, "Daftar Resep", 1)
		@tutup.font.ukuran = 16
		@tutup.font.tebal = false
	end

	def panjang
		return @jendela.panjang / 2
	end

	def perbarui
		perbarui_buka
		@tutup.perbarui
		return if @buka.kepadatan < 100
		cek_penguncian_kanvas
		cek_kursor_gulung
		cek_pilihan
	end

	def cek_pilihan
		return unless @buka.oy == 0
		k = @buka.kursor
		return unless Mouse.klik?
		return pilihan_tidak_ada unless k
		pilih_sebelum = @pilih
		@pilih = (k.y + 5 + @atas) / 50 if ((k.y + 5 + @atas) % 50).between?(5, 45)
		return @pilih = -1 if @pilih >= DataResep.banyak
		@jendela.memilih if pilih_sebelum < 0
		refresh_buka if @pilih != pilih_sebelum && @pilih < DataResep.banyak
	end

	def resep
		DataResep.resep(@pilih)
	end

	def hapus
		DataResep.hapus(@pilih)
		perbarui_resep
	end

	def pilihan_tidak_ada
		@jendela.refresh_menu
		@jendela.tidak_memilih
		@pilih = -1
		refresh_buka
	end

	def cek_kursor_gulung
		k = @buka.kursor
		return unless k
		return if @buka.oy != 0
		kec = PapanTik.menekan?(:SHIFT) ? 10 : 2
		kec *= 2 if PapanTik.menekan?(:KRSHIFT) && PapanTik.menekan?(:KNSHIFT)
		kec *= 3 if PapanTik.menekan?(:SPASI)
		kec = 1 if PapanTik.menekan?(:CTRL)
		if k.y.between?(0, 50)
			@atas -= kec unless @atas < 1
			refresh_buka
		elsif k.y.between?(@buka.lebar - 50, @buka.lebar)
			@atas += kec unless @atas > (DataResep::banyak - 3) * 50
			refresh_buka
		end
	end

	def perbarui_resep
		@petabit.bersihkan
		font = Font.new("Arial", 30)
		DataResep.semua_resep.each_with_index do |resep, indeks|
			@petabit.warnai_area(Area.new(5, indeks * 50 + 5, @buka.panjang - 10, 40), Warna.new(255, 0, 0, 150))
			@petabit.tulis(font, Area.new(15, indeks * 50 + 10, @buka.panjang - 20, 40), resep.nama.to_s, 0)
		end
		refresh_buka
	end

	def refresh_buka
		@buka.warnai_area(0, 0, @buka.panjang, @buka.lebar, Warna.new(190))
		@buka.petabit.jiplak(0, 0, @petabit, Area.new(0, @atas, @buka.panjang, @buka.lebar))
		if @pilih.between?(0, DataResep.banyak - 1)
			@buka.font.ukuran = 30
			@buka.warnai_area(5, @pilih * 50 + 5 - @atas, @buka.panjang - 10, 40, Warna.new(255, 0, 0))
			@buka.tulis(15, @pilih * 50 + 10 - @atas, @buka.panjang - 20, 40, DataResep.resep(@pilih).nama)
			@buka.font.normal
		end
	end

	def perbarui_buka
		return @buka.perbarui if @kunci
		kecepatan = 4
		if @buka.oy < @buka.panjang + 50 && !@pembukaan
			@buka.oy += kecepatan * 2
			@buka.perbarui
		elsif @pembukaan
			fresh = false
			if @buka.oy > 0
				@buka.oy -= kecepatan
				fresh = true
			end
			if fresh && @buka.oy == 0
				@atas = 0
				refresh_buka
			end
			@buka.perbarui
		end
		@pembukaan = true if @tutup.kursor
		@pembukaan = false if @buka.kursor.nil? && @tutup.kursor.nil?
	end

	def cek_penguncian_kanvas
		return unless Mouse.klik?
		return unless (k = @tutup.kursor)
		return unless k.x.between?(@tutup.panjang - 50, @tutup.panjang)
		return unless k.y.between?(0, 20)
		if @kunci
			@tutup.warnai_area(@tutup.panjang - 55, 0, 45, 20, Warna.new(195))
			@tutup.tulis(@tutup.panjang - 50, 0, 50, 20, "kunci")
			@kunci = false
		else
			@buka.oy = 0
			@tutup.font.tebal = true
			@tutup.warnai_area(@tutup.panjang - 55, 0, 45, 20, Warna.new(150))
			@tutup.tulis(@tutup.panjang - 50, 0, 50, 20, "kunci")
			@tutup.font.tebal = false
			@kunci = true
			@atas = 0 unless @buka.oy == 0
		end
	end

	def terbuka?
		@buka.oy.zero?
	end

	def kurangi_kepadatan
		@buka.kepadatan -= 2
		@tutup.kepadatan -= 2
	end

	def tambah_kepadatan
		@buka.kepadatan += 2
		@tutup.kepadatan += 2
	end
end