load "penggulung.rb"
load "resep.rb"
load "rincian.rb"
load "bahan.rb"

class Resep
	attr_accessor :nama, :bahan
end

module Daftar
	file = "../pelengkap/jurnal.txt"
	File.write(file, "{}") unless File.exist?(file)
	@daftar = eval(File.read(file)).collect do |i|
		r = Resep.new
		r.nama = i[0]
		r.bahan = i[1]
		r
	end

	def self.daftar
		@daftar
	end

	def self.tambah(resep)
		@daftar.push(resep)
	end

	def self.simpan
		dasar = "{}"
		isi = @daftar.collect do |i|
			Fiber.yield
			next nil if i.nama.nil? || i.bahan.nil?
			"\t\"" + i.nama + "\"\t=> [" + i.bahan.collect { |i| "\"" + i + "\"" } .join(", ") + "],\n"
		end
		hasil = dasar.insert(1, "\n" + isi.compact.join)
		File.write("jurnal.txt", hasil)
	end

	def self.hapus
		@daftar.size.times do |i|
			Fiber.yield
			@daftar.pop
		end
	end
end

class Pecetak_Resep < JendelaAplikasi
	def initialize
		super("Pencetak Resep", 400, 400)
		@mode = :normal
		@resep = Daftar_Resep.new(self)
		@rincian = Rincian.new(self)
		@bahan = Bahan.new(self)
		@simpan = Kanvas.new(self, 50, 363, 100, 30)
		@bersih = Kanvas.new(self, 230, 363, 100, 30)
		@kanvas = Kanvas.new(self, 0, 0, 400, 400)
		@lain = nil
		awal
	end

	def awal
		@simpan.latar = Warna.new(200, 200, 200)
		@bersih.latar = Warna.new(200, 200, 200)
		@simpan.tulis(28, 5, 100, 20, "Simpan")
		@bersih.tulis(22, 5, 100, 20, "Bersihkan")
		@rincian.ganti(@resep.index)
	end

	def perbarui
		super
		case @mode
		when :normal
			perbarui_normal
		else
			mode
		end
	end

	def perbarui_normal
		PapanTik.perbarui
		@resep.perbarui
		@rincian.perbarui
		@bahan.perbarui
		@simpan.perbarui
		@bersih.perbarui
		cek_perubahan
	end

	def cek_perubahan
		if @rincian.terapkan
			r = Daftar.daftar[@resep.index]
			r.nama = @rincian.judul.clone
			r.bahan = @rincian.daftar.collect.with_index { |v, i| v.nil? ? nil : @rincian.banyak[i].to_s + " " + v } .compact
			@resep.refresh
		elsif @bahan.terpilih || @rincian.tambah?
			@rincian.tambah_bahan(@bahan.bahan)
		elsif Mouse.klik? && kursor && kursor.x.between?(@resep.x, @resep.op + @resep.x) && kursor.y.between?(@resep.y, @resep.ol + @resep.y)
			@rincian.ganti(@resep.index)
		elsif Mouse.klik? && kursor && kursor.x.between?(@simpan.x, @simpan.panjang + @simpan.x) && kursor.y.between?(@simpan.y, @simpan.lebar + @simpan.y)
			@mode = :simpan
		elsif Mouse.klik? && kursor && kursor.x.between?(@bersih.x, @bersih.panjang + @bersih.x) && kursor.y.between?(@bersih.y, @bersih.lebar + @bersih.y)
			@mode = :bersih
		end
	end

	def mode
		if !@lain && @mode == :simpan
			@lain = [0, Fiber.new { Daftar.simpan }, Daftar.daftar.size]
			@lain[1].resume
		elsif !@lain && @mode == :bersih
			@lain = [0, Fiber.new { Daftar.hapus }, Daftar.daftar.size]
			@lain[1].resume
		elsif @lain[0] > 100
			@mode = :normal
			@kanvas.bersihkan
			@lain = nil
			sleep(2)
			return true
		end
		@kanvas.font.ukuran = 50
		@lain[0] += 99.0 / @lain[2]
		@kanvas.warnai_area(0, 0, 400, 400, Warna.new(90, 90, 90, (@lain[0] / 100.0 * 255).to_i))
		70.times do |i|
			sx = (@lain[0] / 100.0 * @kanvas.panjang)
			@kanvas.garis(Area.new(0, 140 + i, 1, 0), Area.new(sx.to_i, 140 + i, 1, 0), Warna.new(255, 255, 255))
		end
		@lain[0] = 100.1 if @lain[0] > 100
		teks = @mode == :simpan ? "Menyimpan... #{@lain[0].to_i}%" : "Menghapus... #{@lain[0].to_i}%"
		@lain[1].resume if @lain && @lain[0] < 100
		@kanvas.tulis(10, 150, 400, 400, teks)
		@kanvas.perbarui
	end
end

def susunan
	jendela = Pecetak_Resep.new
	jendela.perbarui until jendela.nil?
end

susunan