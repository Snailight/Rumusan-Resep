# bahan.rb

class Bahan < Kanvas
	def initialize(jendela)
		super(jendela, 20, 235, 325, 500)
		self.ol = 120
		self.font = Font.new("Times", 18)
		self.latar = @latar = Warna.new(0, 255, 180)
		@index = 0
		@penggulung = Penggulung.new(self)
		@bahan = File.read("../pelengkap/bahan.txt").split(/\n/)
		@terpilih = nil
		refresh
	end

	def refresh
		semua_bahan
		refresh_kursor
	end

	def rect(i)
		r = Area.new
		r.x = (panjang / 2 - 10) * (i % 2) + 10
		r.y = 20 * (i / 2) + 10
		r.panjang = panjang / 2 - 10
		r.lebar = 20
		return r
	end

	def diatas_kursor?
		kursor && kursor.x.between?(x, x + panjang) && kursor.y.between?(y, y + ol)
	end

	def semua_bahan
		@bahan.size.times { |i| refresh_bahan(i) }
	end

	def refresh_bahan(indeks)
		r = rect(indeks)
		bersihkan_area_indeks(indeks)
		tulis(r, @bahan[indeks])
	end

	def bersihkan_area_indeks(indeks)
		r = rect(indeks)
		warnai_area(r.x - 5, r.y - 2, r.panjang, r.lebar + 2, @latar)
	end

	def perbarui
		super
		@penggulung.perbarui
		if diatas_kursor? && Mouse.klik?
			indeks = (kursor.y - y + oy - 10) / 20 * 2 + (kursor.x > panjang / 2 + 10 ? 1 : 0)
			indeks = @bahan.size - 1 if @index >= @bahan.size
			kursor_ke indeks
			@terpilih = true if Mouse.klik_ganda?
		end
	end

	def kursor_ke(indeks)
		refresh_bahan(@index)
		@index = indeks
		refresh_kursor
	end

	def refresh_kursor
		rect = rect(@index)
		warnai_area(rect.x - 5, rect.y - 2, rect.panjang, rect.lebar + 2, Warna.new(255, 255, 255, 150))
	end

	def terpilih
		a = @terpilih
		@terpilih = false
		return a
	end

	def bahan
		@bahan[@index]
	end
end