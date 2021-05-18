json.array! @uploads.items do |upload|
  json.partial! 'item', locals: {item: upload}
end