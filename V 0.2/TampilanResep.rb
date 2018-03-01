class TampilanResep < Kanvas
	def initialize(jendela)
		super(jendela, 10, 10, jendela.panjang - 27, jendela.lebar - 50)
		@proses = nil
		@waktu = 0
		@pencarian = false
		@atas = 0
		@bawah = 0
		@kursor = 0
		@cari = ""
		@ubah_nama_resep = false
		@area_kursor_tulis = Area.new(0, 0, 10, 20)
		@semua_bahan = PetaBit.new(panjang, DataResep::Resep_Maksimum * 40)
		@mode_memilih_bahan = nil
		atur_awal(Resep.new)
	end

	def atur_awal(resep)
		return unless resep.is_a?(Resep)
		@resep = resep
		refresh
	end

	def refresh
		refresh_judul
		refresh_fitur
		refresh_petabit
		refresh_bahan
	end

	def refresh_petabit
		@semua_bahan.warnai_area(Area.new(0, 0, panjang, @bawah), Warna.new(0, 255, 255))

		latar = [Area.new(10, 0, panjang - 20, 30), Warna.new(255, 255, 0, 200)]
		tulis = Area.new(30, 0, panjang - 20, 20)

		saring = @resep.bahan.keys.find_all { |i| i.downcase =~ /#{@cari}/ }
		saring << DataResep::Tambah_Bahan if saring

		saring.each_with_index do |bahan, indeks|
			y = indeks * 40
			latar[0].y = y
			tulis.y = y + 5

			@semua_bahan.warnai_area(*latar)
			@semua_bahan.tulis(font, tulis, bahan, 0)
		end

		@bawah = (@resep.bahan.size + 1) * 40
	end

	def refresh_judul
		nama = @resep.nama
		warnai_area(0, 0, panjang, 70, Warna.new(255, 0, 0))
		warnai_area(5, 5, panjang - 10, 60, Warna.new(200)) if @ubah_nama_resep
		if nama.size <= 20
			font.ukuran = 40
			font.tebal = true
			tulis(0, 0, panjang, 70, nama, 1)
		elsif nama.size <= 50
			font.tebal = true
			(nama =~ /\A(.{0,25})\s(.{0,30})\Z/) || (nama =~ /\A(.{0,25})\s*(.{0,30})\Z/)
			font.ukuran = 30
			tulis(0, 0, panjang, 30, $1, 1)
			font.ukuran = 25
			tulis(0, 32, panjang, 30, $2, 1)
		else
			font.miring = true
			tulis(0, 0, panjang, 70, "Terlalu Panjang", 1)
		end
		font.normal
	end

	def refresh_fitur
		banyak = @kursor < 0 ? 0 : (@resep.bahan.values[@kursor] || 0)
		warnai_area(20, 70, panjang - 40, 40, Warna.new(0, 255, 0))
		warnai_area(40, 75, 50, 30, Warna.new(0, 0, 255))
		font.ukuran = 20
		tulis(50, 80, 60, 20, "Cari")
		warnai_area(panjang - 80, 75, 40, 30, Warna.new(250))
		tulis(panjang - 70, 80, 40, 30, banyak.to_s)
		font.normal
	end

	def refresh_bahan
		warnai_area(0, 110, panjang, lebar - 110, Warna.new(0, 255, 255))
		warnai_area(panjang / 2 - 100, 115, 200, 10, Warna.new(150))
		warnai_area(panjang / 2 - 100, lebar - 20, 200, 10, Warna.new(150))
		petabit.jiplak(0, 130, @semua_bahan, Area.new(0, @atas, panjang, lebar - 150))

		font.ukuran = 14
		tulis(2, lebar - 16, 100, 16, "Total Bahan : #{@resep.bahan.size}")
		warnai_area(panjang - 60, lebar - 20, 50, 16, Warna.new(0, 0, 255, 150))
		tulis(panjang - 60, lebar - 20, 50, 16, "OK", 1)
		font.normal
		
		return if @kursor < 0
		pilih = @resep.bahan.keys[@kursor] || DataResep::Tambah_Bahan
		bahan = @resep.bahan.keys.find_all { |i| i.downcase =~ /#{@cari}/ }
		indeks = @kursor == bahan.size ? bahan.size : bahan.index(pilih)
		return unless indeks
		if (indeks * 40).between?(@atas, @atas + 165) && pilih.downcase =~ /#{@cari}/
			y = indeks * 40 - @atas + 130
			warnai_area(10, y, panjang - 20, 30, Warna.new(255, 255, 0))
			warnai_area(310, y + 5, 15, 20, Warna.new(255, 0, 0))
			warnai_area(330, y + 5, 15, 20, Warna.new(255))
			tulis(30, y + 5, 300, 20, pilih)
		end
	end

	def perbarui
		super
		return if kepadatan < 100
		return if @mode_memilih_bahan
		cek_mouse
		@proses.resume if @proses
		cek_keyboard
	end

	def cek_keyboard
		if @pencarian
			ubah = false
			font.ukuran = 20
			@waktu = 30 if @waktu <= 0
			@waktu -= 1

			PapanTik.tombol.each do |tombol|
				case tombol
				when :hapus
					@cari.slice!(-1, 1)
				when :spasi
					@cari += " " unless @cari.empty?
				when :enter
					@proses = Fiber.new { nonaktifkan_pencarian }
				else
					@cari += tombol.to_s unless tombol.to_s.size > 1 || @cari.size > 26
				end
				@area_kursor_tulis.x = area_teks(@cari).panjang + 50
				ubah = true
			end

			warnai_area(50, 80, 245, 20, Warna.new(255))
			tulis(50, 80, 245, 20, @cari)
			tulis(@area_kursor_tulis, "|") if @waktu < 12
			font.normal

			if ubah
				refresh_petabit
				refresh_bahan
			end
		elsif @ubah_nama_resep
			ubah = false

			PapanTik.tombol.each do |tombol|
				tombol = :":" if tombol == :";"
				case tombol
				when :hapus
					@resep.nama.slice!(-1, 1)
				when :spasi
					@resep.nama += " " unless @resep.nama.empty?
				when :enter
					@ubah_nama_resep = false
				else
					unless tombol.to_s.size > 1 || @resep.nama.size > 50
						@resep.nama += PapanTik.menekan?(:shift) ? tombol.to_s.upcase : tombol.to_s.downcase
					end
				end
				ubah = true
			end

			if ubah
				refresh_judul
			end
		elsif @kursor >= 0
			ubah = false
			return unless @resep.bahan[@resep.bahan.keys[@kursor]]

			PapanTik.tombol.each do |tombol|
				case tombol
				when :hapus
					hasil = @resep.bahan[@resep.bahan.keys[@kursor]].to_s
					hasil.slice!(-1, 1)
					@resep.bahan[@resep.bahan.keys[@kursor]] = hasil.empty? ? 0 : hasil.to_i
				when :atas, :kanan
					@resep.bahan[@resep.bahan.keys[@kursor]] += 1 unless @resep.bahan[@resep.bahan.keys[@kursor]] >= 99
				when :bawah, :kiri
					@resep.bahan[@resep.bahan.keys[@kursor]] -= 1 unless @resep.bahan[@resep.bahan.keys[@kursor]] < 1
				else
					if "1234567890".split(//).any? { |e| e.to_sym == tombol }
						hasil = @resep.bahan[@resep.bahan.keys[@kursor]].to_s + tombol.to_s
						@resep.bahan[@resep.bahan.keys[@kursor]] = hasil.to_i unless hasil.size > 2
					end
				end

				ubah = true
			end

			refresh_fitur if ubah
		end
	end

	def cek_mouse
		k = kursor
		return unless k
		return if @proses
		mouse_pencarian(k) if @pencarian
		mouse_diatas_bahan(k) if k.y.between?(105, lebar)
		mouse_diatas_fitur(k) if k.y.between?(65, 105) && !@pencarian
		mouse_diatas_nama(k) if k.y.between?(0, 65)
	end

	def mouse_diatas_nama(k)
		return unless Mouse.klik_ganda?
		return if @pencarian
		@resep.nama.clear
		@ubah_nama_resep = true
		refresh_judul
	end

	def mouse_pencarian(k)
		if Mouse.klik? && k.x.between?(306, 328) && k.y.between?(75, 95)
			@proses = Fiber.new { nonaktifkan_pencarian }
		end
	end

	def indeks_pencarian(indeks)
		return indeks unless @pencarian
		bahan = @resep.bahan.keys.find_all { |i| i.downcase =~ /#{@cari}/ }
		hasil = @resep.bahan.keys.index(bahan[indeks])
		return hasil ? hasil : @kursor
	end

	def matikan_mode_memilih_bahan(bahan)
		@mode_memilih_bahan = false
		if bahan != :kosong
			daftar = @resep.bahan.to_a
			daftar.delete_at(@kursor)
			daftar.insert(@kursor, [bahan, 1]) unless daftar.any? { |e| e[0] == bahan }
			@resep.bahan = Hash[daftar]
			@kursor = @resep.bahan.keys.index(bahan)
			@atas = (@kursor < 2 ? 0 : @kursor - 2) * 40
		end
		refresh
	end

	def mouse_diatas_bahan(k)
		ubah = false
		if Mouse.klik? && k.y.between?(130, lebar - 30) && !@ubah_nama_resep
			@kursor = indeks_pencarian((k.y - 115 + @atas) / 40)
			if k.x.between?(306, 321)
				@resep.bahan.delete(@resep.bahan.keys[@kursor])
				@kursor = -1
				refresh_petabit
			elsif k.x.between?(326, 341)
				@mode_memilih_bahan = true
				refresh_bahan
				jendela.tampilkan_bahan
			end
			ubah = true
		end

		if k.x.between?(panjang / 2 - 100, panjang / 2 + 100) && !@pencarian
			nilai = Mouse.menekan? ? 5 : 1
			if k.y.between?(110, 120)
				@atas -= nilai unless @atas < 0 + nilai
				ubah = true
			elsif k.y.between?(lebar - 25, lebar - 15)
				@atas += nilai unless @atas > (@resep.bahan.size - 3) * 40 - nilai
				ubah = true
			end
		end

		if k.x.between?(309, 358) && k.y.between?(325, 341)
			jendela.kembali_menu_awal if Mouse.klik?
		end

		if ubah
			refresh_bahan
			refresh_fitur unless @pencarian
		end
	end

	def mouse_diatas_fitur(k)
		return unless k.x.between?(15, panjang - 25)
		return if @ubah_nama_resep
		@proses = Fiber.new { aktifkan_pencarian } if k.x.between?(35, 85) && k.y.between?(75, 105) && Mouse.klik?
	end

	def aktifkan_pencarian
		@atas = 0
		area_cari = Area.new(40, 75, 50, 30)
		alpha_banyak = 255
		warna_tulisan = Warna.new(0, 255)
		until area_cari.x >= 320
			warnai_area(20, 70, panjang - 40, 40, Warna.new(0, 255, 0))
			warnai_area(area_cari, Warna.new(0, 0, 255))
			warnai_area(45, 78, area_cari.x - 45, 25, Warna.new(255))
			warnai_area(panjang - 80, 75, 40, 30, Warna.new(250, alpha_banyak))
			warna_tulisan.alpha = alpha_banyak
			font.warna = warna_tulisan

			area_cari.x += 10
			alpha_banyak -= 10 unless alpha_banyak < 10
			area_cari.panjang -= 1
			Fiber.yield
		end
		area_cari.x -= 10
		warnai_area(area_cari, Warna.new(0, 0, 255))
		font.ukuran = 20
		font.warna = Warna.new(0)
		tulis(area_cari.x + 5, 80, 60, 20, "X")
		font.normal
		refresh_bahan

		@area_kursor_tulis.x = 50
		@area_kursor_tulis.y = 80
		@proses = nil
		@pencarian = true
		@waktu = 10
	end

	def nonaktifkan_pencarian
		@atas = 0
		@pencarian = false
		@cari.clear

		area_cari = Area.new(310, 75, 22, 30)
		alpha_banyak = 0
		warna_tulisan = Warna.new(0, 0)
		until area_cari.x <= 40
			warnai_area(20, 70, panjang - 40, 40, Warna.new(0, 255, 0))
			warnai_area(area_cari, Warna.new(0, 0, 255))
			warnai_area(45, 78, area_cari.x - 45, 25, Warna.new(255))
			warnai_area(panjang - 80, 75, 40, 30, Warna.new(250, alpha_banyak))
			warna_tulisan.alpha = alpha_banyak
			font.warna = warna_tulisan

			area_cari.x -= 10
			alpha_banyak = alpha_banyak >= 255 ? 255 : alpha_banyak + 10
			area_cari.panjang += 1
			Fiber.yield
		end

		@waktu = 0
		@proses = nil
		font.warna = Warna.new(0)
		refresh_fitur
	end
end