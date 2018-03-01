class MenuUtama
	def initialize
		buat_judul
		buat_latar_belakang
		buat_menu_inti
	end

	def warna_latar
		Warna.new(200, 200, 100)
	end

	def nama_program
		return "Rumusan Resep"
	end

	def versi_program
		"V 1.0"
	end

	def daftar_menu_inti
		[
			"Daftar Resep",
			"Ubah Bahan",
			"Perbarui Informasi",
			"Lihat Hasil",
			"Tentang Program",
			"Keluar"
		]
	end

	def buat_judul
		@judul = Kanvas.new(0, 0, Jendela.panjang, 100)
		@judul.warnai_area(0, 0, @judul.panjang, @judul.lebar, warna_latar)
		@judul.font.ukuran = 40
		@judul.font.tebal = true
		@judul.font.warna = Warna.new(0, 0, 255)
		@judul.tulis(0, 0, @judul.panjang, @judul.lebar, nama_program, 1)
		@judul.font.normal
		@judul.tulis(0, 0, @judul.panjang - 20, @judul.lebar - 10, versi_program, 2)
		@judul.warnai_area(0, @judul.lebar - 1, @judul.panjang, 1, Warna.new(255, 255, 0))
	end

	def buat_latar_belakang
		@latar = Kanvas.new(0, 0, Jendela.panjang, Jendela.lebar)
		@latar.warnai_area(0, 0, @latar.panjang, @latar.lebar, warna_latar)
	end

	def buat_menu_inti
		@menu_inti = daftar_menu_inti.collect.with_index do |nama_menu, indeks|
			tombol = Tombol_MenuInti.new(indeks, nama_menu)
			tombol.perintah = method(:proses_menu)
			tombol
		end
	end

	def proses_menu(nama_menu)
		p nama_menu
	end

	def perbarui
		@latar.perbarui
		@judul.perbarui
		@menu_inti.each(&:perbarui)
	end
end