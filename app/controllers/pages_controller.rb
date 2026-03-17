require './app/models/pesan'

class PagesController < Eksa::Controller
  def index
    if request.post? && params['konten']
      Pesan.buat(params['konten'], params['pengirim'])
      return redirect_to "/", notice: "Pesan berhasil terkirim ke database!"
    end

    if params['q'] && !params['q'].empty?
      @semua_pesan = Pesan.cari_kata(params['q'])
      @keyword = params['q']
    else
      @semua_pesan = Pesan.semua
    end

    @nama = params['nama'] || "Developer"
    render :index
  end

  def about
    render :about
  end

  def docs
    render :docs
  end

  def kontak
    render :kontak
  end

  def conduct
    render :conduct
  end

  def security
    render :security
  end

  def edit
    @id = params['id']
    @pesan = Pesan.cari(@id)

    return redirect_to "/", notice: "Pesan tidak ditemukan!" if @pesan.nil?

    if request.post?
      Pesan.update(@id, params['konten'], params['pengirim'])
      return redirect_to "/", notice: "Perubahan pesan berhasil disimpan."
    end

    render :edit
  end

  def hapus_pesan
    if params['id']
      Pesan.hapus(params['id'])
      return redirect_to "/", notice: "Pesan telah berhasil dihapus."
    end
    redirect_to "/"
  end
end