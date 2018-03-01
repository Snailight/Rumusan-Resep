class Tombol_MenuInti < Kanvas
	attr_accessor :perintah

	def initialize(indeks, nama)
		super(-20, indeks * (lebar_tombol + jarak_tombol) + titik_y_menu, 300, lebar_tombol)
		@nama = nama
		@aktif = false
		font.ukuran = 20
		refresh
	end

	def titik_y_menu
		return 140
	end

	def lebar_tombol
		return 40
	end

	def jarak_tombol
		return 20
	end

	def kecepatan_aktif
		return 5
	end

	def warna_tombol(cerah = 0)
		asli = Warna.new(100, 100, 255)
		asli.merah += (cerah * (255 - asli.merah).to_f / 20.0).to_i
		asli.hijau += (cerah * (255 - asli.hijau).to_f / 20.0).to_i
		asli.biru += (cerah * (255 - asli.biru).to_f / 20.0).to_i
		return asli
	end

	def refresh
		warnai_area(0, 0, panjang, lebar, warna_tombol)
		20.times { |n| warnai_area(20 - n - 1, 0, 1, lebar, warna_tombol(n)) }
		tulis(40, lebar_tombol / 2 - font.ukuran / 2, panjang, font.ukuran, @nama, 0)
	end

	def perbarui
		super
		sebelum = @aktif
		perbarui_aktif
		cocokkan_gambar if sebelum != @aktif || Mouse.klik? || Mouse.dilepas?
		jalankan_perintah if Mouse.dilepas? && @aktif
	end

	def perbarui_aktif
		k = Jendela.kursor
		return unless k
		if k.y.between?(y, y + lebar)
			self.x += kecepatan_aktif if self.x < 0
			@aktif = k.x.between?(x, x + panjang) if self.x == 0
		elsif self.x > -20
			self.x -= kecepatan_aktif
			@aktif = false if @aktif
		end
	end

	def cocokkan_gambar
		refresh
		warna = warna_tombol(Mouse.ditekan? ? -5 : 10)
		warna.alpha = 150
		if @aktif
			warnai_area(0, 0, panjang, lebar, warna)
			tulis(40, lebar_tombol / 2 - font.ukuran / 2, panjang, font.ukuran, @nama, 0)
		end
	end

	def jalankan_perintah
		return unless perintah
		perintah.call(@nama)
	end
end