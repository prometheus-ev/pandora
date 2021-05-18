require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  if production_sources_available?
    test "should return the empty string as rights representative for an elastic record" do
      jdoe = Account.find_by! login: 'jdoe'
      super_image = Pandora::SuperImage.new('robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc')
      image = super_image.image

      assert image.rights_representative == ''
    end

    test "should return the given string translated as rights representative for an elastic record" do
      jdoe = Account.find_by! login: 'jdoe'
      super_image = Pandora::SuperImage.new('robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc')
      image = super_image.image
      image.elastic_record_image.rights_work = ['Unknown']

      assert image.rights_representative == 'Unknown'.t
    end

    test "should return the given string escaped as rights representative for an elastic record" do
      jdoe = Account.find_by! login: 'jdoe'
      super_image = Pandora::SuperImage.new('robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc')
      image = super_image.image
      image.elastic_record_image.rights_work = ['<b>My own right!</b>']

      assert image.rights_representative == '&lt;b&gt;My own right!&lt;/b&gt;'
    end

    test "should return the warburg rights representative for an elastic record" do
      jdoe = Account.find_by! login: 'jdoe'
      super_image = Pandora::SuperImage.new('robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc')
      image = super_image.image
      image.elastic_record_image.rights_work = ['rights_work_warburg']

      assert image.rights_representative == 'The Warburg Institute, London'
    end

    test "should return the vgbk rights representative for an elastic record" do
      jdoe = Account.find_by! login: 'jdoe'
      super_image = Pandora::SuperImage.new('robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc')
      image = super_image.image
      image.elastic_record_image.rights_work = ['rights_work_vgbk']

      assert image.rights_representative == 'VG Bild-Kunst'
    end
  end

  test "should return the given string as rights representative for an upload record" do
    jdoe = Account.find_by! login: 'jdoe'
    upload = create_upload('leonardo', { rights_work: 'I have some work & rights!' })

    assert upload.image.rights_representative == 'I have some work &amp; rights!'
  end

  test "should return the warburg rights representative for a warburg image" do
    jdoe = Account.find_by! login: 'jdoe'
    upload = create_upload('leonardo', { rights_work: 'rights_work_warburg' })

    assert upload.image.rights_representative == 'The Warburg Institute, London'
  end

  test "should return the vgbk rights representative for a vgbk image" do
    jdoe = Account.find_by! login: 'jdoe'
    upload = create_upload('leonardo', { rights_work: 'rights_work_vgbk' })

    assert upload.image.rights_representative == 'VG Bild-Kunst'
  end

  test "should return the public domain rights representative translated for a public domain upload image" do
    jdoe = Account.find_by! login: 'jdoe'
    upload = create_upload('leonardo', { rights_work: 'In the public domain' })

    assert upload.image.rights_representative == 'In the public domain'.t
  end

  test "should return unknown representative translated for an unknown upload image" do
    jdoe = Account.find_by! login: 'jdoe'
    upload = create_upload('leonardo', { rights_work: 'Unknown' })

    assert upload.image.rights_representative == 'Unknown'.t
  end
end
