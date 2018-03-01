class Menu < Kanvas
	attr_reader :tipe

	def initialize(jendela, x, y, tipe)
		super(jendela, x, y, 64, 64)
		nama_menu(tipe)
		@tipe = tipe
		@aktif = true
		@fiber = nil

		case @tipe
		when :buka
			@aktif = false
			refresh
			self.ox = -panjang
		when :hapus
			@aktif = false
			refresh
			self.ox = -panjang
		when :tambah
			refresh
			self.ox = -panjang
		else
			refresh
		end
	end

	def nama_menu(tipe)
		@nama = case tipe
		when :simpan 		; "Simpan"
		when :buka 			; "Buka"
		when :hapus 		; "Hapus"
		when :tambah 		; "Tambah"
		when :bantuan 		; "Bantuan"
		when :keluar 		; "Keluar"
		when :kredit 		; "Kredit"
		when :versi 		; "Versi"
		when :hapus_semua 	; "Bersih"
		when :salin			; "Salin"
		end
	end

	def aktifkan
		@aktif = true
		refresh(true)
	end

	def nonaktifkan
		@aktif = false
		refresh(true)
	end

	def aktif?
		@aktif
	end

	def gambar_ikon
		case @tipe
		when :simpan
			lingkaran(12, 12, 20, Warna.new(240))
			lingkaran(26, 26, 6, Warna.new(255, 255, 0))
		when :buka
			lingkaran(14, 14, 14, Warna.new(250))
			lingkaran(18, 18, 10, Warna.new(255, 255, 0))
			lingkaran(18, 18, 10, Warna.new(200, 100))
			garis(38, 38, 45, 45, Warna.new(0))
			garis(39, 37, 46, 44, Warna.new(0))
			garis(37, 39, 44, 46, Warna.new(0))
			garis(36, 40, 43, 47, Warna.new(0))
		when :hapus
			warnai_area(11, 30, 40, 12, Warna.new(0, 200))
			warnai_area(12, 31, 38, 10, Warna.new(255, 230))
			garis(40, 38, 50, 48, Warna.new(255, 0, 0))
			garis(50, 38, 40, 48, Warna.new(255, 0, 0))
		when :tambah
			warnai_area(11, 30, 40, 12, Warna.new(0, 200))
			warnai_area(12, 31, 38, 10, Warna.new(255, 230))
			warnai_area(45, 38, 2, 10, Warna.new(0, 0, 255))
			warnai_area(41, 42, 10, 2, Warna.new(0, 0, 255))
		when :bantuan
			font.warna = Warna.new(255, 0, 0)
			font.tebal = true
			font.ukuran = 30
			tulis(0, 0, 64, 64, "??", 1)
			font.tebal = false
			font.ukuran = 16
		when :keluar
			warnai_area(15, 15, 34, 10, Warna.new(0, 0, 255, 200))
			warnai_area(15, 25, 34, 20, Warna.new(250, 200))
			garis(40, 40, 50, 50, Warna.new(255, 0, 0))
			garis(50, 40, 40, 50, Warna.new(255, 0, 0))
		when :kredit
			warnai_area(15, 10, 25, 35, Warna.new(0))
			warnai_area(16, 11, 25, 35, Warna.new(230))
			warnai_area(25, 20, 25, 35, Warna.new(0))
			warnai_area(26, 21, 25, 35, Warna.new(230))
		when :versi
			font.ukuran = 30
			font.tebal = true
			font.miring = true
			tulis(0, 0, panjang, lebar, "V", 1)
			font.tebal = false
			font.miring = false
			font.ukuran = 16
		when :hapus_semua
			3.times do |i|
				warnai_area(11, 10 + 15 * i, 40, 12, Warna.new(0, 200))
				warnai_area(12, 11 + 15 * i, 38, 10, Warna.new(255, 230))
				garis(40, 10 + 15 * i, 50, 20 + 15 * i, Warna.new(255, 0, 0))
				garis(50, 10 + 15 * i, 40, 20 + 15 * i, Warna.new(255, 0, 0))
			end
		when :salin
			font.ukuran = 30
			tulis(0, 0, panjang, lebar, "VXA", 1)
			font.normal
		end
		warnai_area(0, 0, panjang, lebar, Warna.new(0, 100)) unless aktif?
	end

	def perbarui
		super
		return if kepadatan < 100
		perbarui_sesuai_tipe
		refresh
	end
	
	def perbarui_sesuai_tipe
		case @tipe
		when :simpan
			self.oy += 1 if jendela.pilihan_resep_terbuka? && self.oy < lebar
			self.oy -= 1 if !jendela.pilihan_resep_terbuka? && self.oy > 0
		when :salin
			self.oy += 1 if jendela.pilihan_resep_terbuka? && self.oy < lebar
			self.oy -= 1 if !jendela.pilihan_resep_terbuka? && self.oy > 0
		when :buka
			self.ox += 1 if jendela.pilihan_resep_terbuka? && self.ox < 0
			self.ox -= 1 if !jendela.pilihan_resep_terbuka? && self.ox > -panjang
		when :hapus
			self.ox += 1 if jendela.pilihan_resep_terbuka? && self.ox < 0
			self.ox -= 1 if !jendela.pilihan_resep_terbuka? && self.ox > -panjang
		when :bantuan
			self.ox -= 1 if jendela.pilihan_resep_terbuka? && self.ox > -panjang
			self.ox += 1 if !jendela.pilihan_resep_terbuka? && self.ox < 0
		when :tambah
			self.ox += 1 if jendela.pilihan_resep_terbuka? && self.ox < 0
			self.ox -= 1 if !jendela.pilihan_resep_terbuka? && self.ox > -panjang
		when :kredit
			self.oy += 1 if !jendela.pilihan_resep_terbuka? && self.oy < 0
			self.oy -= 1 if jendela.pilihan_resep_terbuka? && self.oy > -lebar
		when :versi
			self.oy += 1 if !jendela.pilihan_resep_terbuka? && self.oy < 0
			self.oy -= 1 if jendela.pilihan_resep_terbuka? && self.oy > -lebar
		when :hapus_semua
			self.oy += 1 if !jendela.pilihan_resep_terbuka? && self.oy < 0
			self.oy -= 1 if jendela.pilihan_resep_terbuka? && self.oy > -lebar
		end
	end

	def refresh(ganti=false)
		return @fiber.resume if @fiber
		if ox != 0 || oy != 0
			if ganti && !@fiber
				@fiber = Fiber.new { tunggu_ox_oy }
			end
			return nil
		end
		s = @kondisi
		if kursor && Mouse.menekan? && aktif?
			@kondisi = 2
		elsif kursor && aktif?
			@kondisi = 1
		else
			@kondisi = 0
		end

		if @kondisi != s || ganti
			perbarui_latar
			gambar_ikon
			font.tebal = true
			tulis(0, 45, panjang, 16, @nama, 1) if s == 0 && @kondisi == 1
			font.tebal = false
			fungsi_menu if s == 2
		end
	end

	def tunggu_ox_oy
		Fiber.yield while ox != 0 || oy != 0
		@fiber = nil
		refresh(true)
	end

	def perbarui_latar
		case @kondisi
		when 0
			7.times { |i| warnai_area(i, i, 64 - i * 2, 64 - i * 2, Warna.new(180 + i * 10 , 180 + i * 10, 0)) }
		when 1
			7.times { |i| warnai_area(i, i, 64 - i * 2, 64 - i * 2, Warna.new(231 + i * 4, 231 + i * 4, 0)) }	
		when 2
			7.times { |i| warnai_area(i, i, 64 - i * 2, 64 - i * 2, Warna.new(100 + i * 10 , 100 + i * 10, 0)) }
		end
	end

	def fungsi_menu
		case @tipe
		when :tambah
			jendela.tambah_resep
		when :keluar
			jendela.selesai
		when :buka
			jendela.buka_resep
		when :hapus
			jendela.hapus_resep
		when :hapus_semua
			jendela.hapus_semua
		when :simpan
			puts XML.ke_xml(DataResep.semua_resep)
			File.write("daftar_resep.xml", XML.ke_xml(DataResep.semua_resep))
		when :versi
			tahan_jendela(&method(:tahan_jendela_versi))
		when :kredit
			tahan_jendela(&method(:tahan_jendela_kredit))
		when :salin
			salin_resep = {}
			DataResep.semua_resep.each do |resep|
				bahan = resep.bahan.collect do |bahan, banyak|
					sprintf("%d %s", banyak, bahan)
				end
				salin_resep[resep.nama] = bahan
			end
			text = salin_resep.inspect
			text.insert(1, "\n")
			text.gsub!(/(\"[\w \-]+\")\=\>(\[[ *\"\d+ \w+\"\,]*\])(\,*)/) { sprintf("\t%s => %s%s\n", $1, $2, $3) }
			PapanTempel.tulisan = text
		end
	end

	def tahan_jendela(&block)
		tutup = Kanvas.new(jendela, 0, 0, jendela.panjang, jendela.lebar)
		tutup.latar = Warna.new(0)
		kanvas = Kanvas.new(jendela, jendela.panjang / 2 - 140, jendela.lebar / 2 - 100, 280, 200)
		kanvas.warnai_area(0, 0, 280, 200, Warna.new(255, 255, 0, 100))
		kanvas.warnai_area(2, 2, 280 - 4, 200 - 4, Warna.new(255, 255, 0, 140))
		kanvas.warnai_area(4, 4, 280 - 8, 200 - 8, Warna.new(255, 255, 0, 180))
		kanvas.warnai_area(6, 6, 280 - 12, 200 - 12, Warna.new(255, 255, 0, 220))
		kanvas.warnai_area(8, 8, 280 - 16, 200 - 16, Warna.new(255, 255, 0, 255))
		block.call(kanvas)
		PapanTik.perbarui
		jendela.nonaktifkan
		until PapanTik.terpicu?(:enter) || PapanTik.terpicu?(:spasi) || Mouse.klik?
			jendela.perbarui
			tutup.perbarui
			kanvas.perbarui
		end
		jendela.aktifkan
	end

	def tahan_jendela_versi(kanvas)
		kanvas.font.ukuran = 20
		kanvas.tulis(10, 10, 260, 25, "Tanggal Rilis :  " + DataResep::TANGGAL[0])
		kanvas.tulis(120, 27, 260, 25, DataResep::TANGGAL[1])
		kanvas.tulis(10, 60, 260, 25, "Versi " + DataResep::VERSI)
		kanvas.tulis(10, 80, 260, 25, "Copyright " + DataResep::COPYRIGHT)
		kanvas.font.ukuran = 16
		kanvas.tulis(10, 110, 260, 25, DataResep::PENGHORMATAN)
		kanvas.font.ukuran = 14
		kanvas.tulis(10, 140, 260, 25, DataResep::PESAN_PEMBUAT[0])
		kanvas.tulis(10, 150, 260, 25, DataResep::PESAN_PEMBUAT[1])
		kanvas.tulis(10, 170, 260, 25, DataResep::KONTAK)
	end

	def tahan_jendela_kredit(kanvas)
		kanvas.font.ukuran = 20
		kanvas.tulis(10, 10, 260, 25, "Terimakasih pemuda Indonesia")
		kanvas.tulis(10, 28, 260, 25, "yang telah berpartisipasi")
		kanvas.tulis(10, 46, 260, 25, "dalam membangun bangsa")
		kanvas.font.ukuran = 14
		kanvas.tulis(10, 140, 260, 25, DataResep::PESAN_PEMBUAT[0])
		kanvas.tulis(10, 150, 260, 25, DataResep::PESAN_PEMBUAT[1])
		kanvas.tulis(10, 170, 260, 25, DataResep::KONTAK)
	end

	def tutup
		self.ox -= 1
	end

	def kembali
		self.ox = 0
	end
end