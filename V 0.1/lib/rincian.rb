# rincian.rb

class Rincian < Kanvas
	attr_reader :judul
	attr_reader :daftar
	attr_reader :banyak

	def initialize(jendela)
		super(jendela, 170, 0, 200, 230)
		@index = 0
		@bahan = Kanvas.new(jendela, 180, 100, 160, 180)
		@peringatan = [0] * 6
		@bahan.ol = 120
		@penggulung = Penggulung.new(@bahan)
		@daftar = []
		@banyak = []
		@judul = ""
		@x_batas = 13
		@terapkan = false
		refresh
	end

	def refresh
		self.latar = Warna.new(255, 255, 0)
		petakan_rincian
	end

	def judul_rincian
		tulis(10, 20, 50, 20, "Nama :")
		tulis(10, 80, 50, 20, "Bahan :")
	end

	def petakan_rincian
		judul_rincian
		petakan_nama
		petakan_bahan
		refresh_penggulung
	end

	def petakan_nama
		nama = Area.new(10, 40, 170, 25)
		warnai_area(nama, Warna.new(255, 255, 255))
		garis(nama.x, nama.y, nama.x + nama.panjang, nama.y, Warna.new(0, 0, 0))
		garis(nama.x, nama.y, nama.x, nama.y + nama.lebar, Warna.new(0, 0, 0))
		garis(nama.x + nama.panjang, nama.y, nama.x + nama.panjang, nama.y + nama.lebar, Warna.new(0, 0, 0))
		garis(nama.x, nama.y + nama.lebar, nama.x + nama.panjang, nama.y + nama.lebar, Warna.new(0, 0, 0))
	end

	def petakan_bahan
		@latar_bahan = Warna.new(235, 235, 200)
		(@bahan.lebar / 20).times { |i| petakan_bahan_index(i) }
	end

	def petakan_bahan_index(indeks)
		bersihkan_area_bahan_index(indeks)
		@bahan.tulis(10, indeks * 20 + 2, @bahan.panjang - 10, 20, "#{@banyak[indeks]} #{@daftar[indeks]}")
		@bahan.garis(0, indeks * 20, @bahan.panjang, indeks * 20, Warna.new(0, 0, 0))
		indeks += 1
		@bahan.garis(0, indeks * 20, @bahan.panjang, indeks * 20, Warna.new(0, 0, 0))
	end
	
	def self.oy=(l)
		super(l)
		refresh_penggulung
	end

	def refresh_penggulung
		@penggulung.latar = Warna.new(255, 255, 0)
		@penggulung.refresh
	end

	def perbarui
		super
		cek_peringatan
		@bahan.perbarui
		@penggulung.perbarui
		proses_tombol(PapanTik.tombol)
		masukan
	end

	def proses_tombol(tombol)
		return unless tombol
		return unless spesial?(tombol)
		huruf = PapanTik.menekan?(:SHIFT) ? tombol.to_s.upcase : tombol.to_s.downcase
		tulis(@x_batas, 41, 20, 20, huruf)
		@x_batas += area_teks(huruf).panjang
		@judul += huruf
	end

	def spesial?(tombol)
		sp = ["SPASI","HAPUS","ATAS","KANAN","KIRI","BAWAH","CTRL","ALT","CAPSLOCK","TAB","ENTER","ESC","SHIFT"].select {|i| i==tombol.to_s}
		case sp[0]
		when "HAPUS"
			j = @judul.slice!(-1, 1)
			@x_batas -= area_teks(j).panjang
			warnai_area(@x_batas, 41, area_teks(j).panjang, area_teks(j).lebar, Warna.new(255, 255, 255))
		when "SPASI"
			@judul += " "
			@x_batas += area_teks(" ").panjang
		when "ENTER"
			@terapkan = true
		when "KANAN"
			(@banyak[@index] >= 99 ? peringatan(0, 0, 255, 15, @index) : @banyak[@index] += 1) unless @banyak[@index].nil?
			petakan_bahan
			refresh_kursor
		when "KIRI"
			((@banyak[@index] <= 1 || PapanTik.menekan(:CTRL)) ? hapus_bahan(@index) : @banyak[@index] -= 1) unless @banyak[@index].nil?
			petakan_bahan
			refresh_kursor
		when "ATAS"
			if @index * 20 - @bahan.oy < 0 && @index > 0
				@bahan.oy -= 30
				perbarui
			end
			PapanTik.menekan(:CTRL) ? @tambahkan = true : (self.kursor = @index - 1 if @index > 0)
		when "BAWAH"
			if (@index + 1) * 20 - @bahan.oy > @bahan.ol && @index < 9
				@bahan.oy += 30
				perbarui
			end
			self.kursor = @index + 1 if @index < @banyak.size
		end
		return sp.empty?
	end

	def kursor=(index)
		petakan_bahan_index(@index)
		@index = index
		refresh_kursor
	end

	def terapkan
		g = @terapkan
		@terapkan = false
		return g
	end

	def ganti(index)
		@daftar.clear
		@banyak.clear
		@judul = Daftar.daftar[index].nama || ""
		warnai_area(13, 41, 167, 16, Warna.new(255, 255, 255))
		tulis(13, 41, 167, 16, @judul)
		@x_batas = 13 + area_teks(@judul).panjang
		daftar = Daftar.daftar[index].bahan
		return if daftar.nil?
		daftar.each do |i|
			i = i.clone
			@banyak.push(i.slice!(/[\d]+/).to_i)
			i.slice!(" ")
			@daftar.push(i)
		end
		petakan_bahan
		refresh_kursor
	end

	def masukan
		kursor = kursor()
		return unless Mouse.klik? && kursor
		return unless kursor.x.between?(@bahan.x, @bahan.x + @bahan.op) && kursor.y.between?(@bahan.y, @bahan.y + @bahan.ol)
		self.kursor = (kursor.y - @bahan.y + @bahan.oy) / 20
	end

	def refresh_kursor
		petakan_bahan_index(@index)
		@bahan.warnai_area(0, @index * 20, @bahan.panjang, 20, Warna.new(0, 0, 255, 100))
	end

	def bersihkan_area_bahan_index(index)
		@bahan.warnai_area(0, index * 20, @bahan.panjang, 20, @latar_bahan)
	end

	def tambah_bahan(bahan)
		return bahan_sudah_ada(bahan) if @daftar.any? { |i| i == bahan }
		@daftar[@index] = bahan
		@banyak[@index] = 1
		petakan_bahan
		refresh_kursor
		@bahan.oy = @index * 20 unless (@index * 20).between?(@bahan.oy, @bahan.ol + @bahan.oy)
	end

	def hapus_bahan(index)
		@daftar.delete_at(index)
		@banyak.delete_at(index)
		peringatan(255, 0, 255, 10, index)
	end

	def bahan_sudah_ada(bahan)
		i = @daftar.index(bahan)
		peringatan(255, 0, 0, 15, i)
		@bahan.oy = i * 20 unless (i * 20).between?(@bahan.oy, @bahan.ol + @bahan.oy)
	end

	def peringatan(merah, hijau, biru, waktu, index)
		@peringatan[0] = merah
		@peringatan[1] = hijau
		@peringatan[2] = biru
		@peringatan[3] = waktu
		@peringatan[4] = index
		@peringatan[5] = 0
	end

	def cek_peringatan
		return if @peringatan[3] - @peringatan[5] < 1
		i = @peringatan[4]
		@bahan.bersihkan_area(0, i * 20, @bahan.panjang, 20)
		@bahan.warnai_area(0, i * 20, @bahan.panjang, 20, Warna.new(235, 235, 200))
		@bahan.tulis(10, i * 20 + 2, @bahan.panjang - 10, 20, "#{@banyak[i]} #{@daftar[i]}")
		@bahan.garis(Area.new(0, (i + 1) * 20, 1, 0), Area.new(@bahan.panjang, (i + 1) * 20, 1, 0), Warna.new(0, 0, 0))
		refresh_kursor
		warna = [*@peringatan[0..2], ((@peringatan[3] - @peringatan[5] - 1).to_f / @peringatan[3].to_f * 255.0).to_i]
		@bahan.warnai_area(0, i * 20, @bahan.panjang, 20, Warna.new(*warna))
		@peringatan[5] += 1
	end

	def tambah?
		a = @tambahkan
		@tambahkan = false
		return a
	end
end