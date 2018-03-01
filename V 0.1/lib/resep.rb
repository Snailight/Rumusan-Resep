# resep.rb

class Daftar_Resep < Kanvas
	attr_reader :index

	def initialize(jendela)
		super(jendela, 20, 30, 100, 1000)
		@jeda = 1
		self.ol = 200
		@index = 0
		@penggulung = Penggulung.new(self, ol - 45)
		@info = Kanvas.new(jendela, self.x, self.y - 30, panjang + 5 + 20, 25)
		@info.latar = Warna.new(150, 140, 167)
		@tambah = Kanvas.new(jendela, @penggulung.x, y + ol - 20 * 2, @penggulung.panjang, 20)
		@kurangi = Kanvas.new(jendela, @penggulung.x, y + ol - 20, @penggulung.panjang, 20)
		Daftar.tambah(Resep.new) if Daftar.daftar.empty?
		awalan
	end

	def awalan
		@info.tulis(5, 5, 100, 20, "Daftar Resep")
		@tambah.font.ukuran = 25
		@kurangi.font.ukuran = 30
		refresh
	end

	def perbarui
		super
		cek_jeda
		@penggulung.perbarui
		@info.perbarui
		@tambah.perbarui
		@kurangi.perbarui
		masukan
	end

	def cek_jeda
		return unless @jeda > 0
		@tambah.bersihkan
		@kurangi.bersihkan
		@tambah.latar = Warna.new(220, 200, 160)
		@kurangi.latar = Warna.new(220, 200, 160)
		if @jeda == 1
			@tambah.latar = Warna.new(200, 170, 150)
			@kurangi.latar = Warna.new(200, 170, 150)
			@tambah.tulis(4, -1, 25, 25, "+")
			@tambah.garis(0, @tambah.lebar - 1, @tambah.panjang, @tambah.lebar, Warna.new(0, 0, 0))
			@kurangi.tulis(5, -8, 25, 25, "-")
			@kurangi.garis(0, 0, @tambah.panjang, 0, Warna.new(0, 0, 0))
		end
		@jeda -= 1
	end

	def refresh
		bersihkan
		self.latar = Warna.new(255, 255, 255)
		(Daftar.daftar.size + 1).times { |i| garis(0, i * 20, panjang, i * 20, Warna.new(0, 0, 0)) }
		warnai_area(0, @index * 20, 100, 20, Warna.new(40, 40, 255))
		Daftar.daftar.each_with_index do |v, i|
			tulis(5, i * 20, 100, 20, v.nama || "<kosong>")
		end
		@info.warnai_area(90, 5, 50, 20, Warna.new(150, 140, 167))
		@info.tulis(90, 5, 50, 20, "#{Daftar.daftar.size}/#{lebar / 20}")
	end

	def masukan
		return unless Mouse.klik? && kursor && @jeda < 1
		kursor = kursor()
		if kursor.x.between?(x, x + op) && kursor.y.between?(y, y + ol)
			@index = (kursor.y - y + oy) / 20
			@index = Daftar.daftar.size - 1 if @index > Daftar.daftar.size
		elsif kursor.x.between?(@tambah.x, @tambah.x + @tambah.panjang) && kursor.y.between?(@tambah.y, @tambah.y + @tambah.lebar)
			Daftar.tambah(Resep.new)
			@index = Daftar.daftar.size - 1
			@jeda = 25
		elsif kursor.x.between?(@kurangi.x, @kurangi.x + @kurangi.panjang) && kursor.y.between?(@kurangi.y, @kurangi.y + @kurangi.lebar)
			return if Daftar.daftar.size == 1
			Daftar.daftar.delete_at(@index)
			@index = Daftar.daftar.size - 1 if @index >= Daftar.daftar.size
			@jeda = 25
		end
		refresh
	end
end