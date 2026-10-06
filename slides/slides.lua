-- Filters that adapt the book chapters for revealjs without editing them.

-- 1. The chapters use '---' as visual separators. In revealjs a
--    horizontal rule starts a new slide, which leaves empty slides.
local function drop_rules(blocks)
  return blocks:filter(function(b) return b.t ~= "HorizontalRule" end)
end

-- 2. A level-1 heading becomes a centred section-title slide, and those
--    do not scroll, so long content under it is cut off (e.g. Key
--    Takeaways, Exercises). If a level-1 heading has content directly
--    under it, make it a normal level-2 slide, which scrolls.
local function demote_level1_with_content(blocks)
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      local nxt = blocks[i + 1]
      if nxt and nxt.t ~= "Header" then
        b.level = 2
      end
    end
  end
  return blocks
end

-- 3. Each slide file has a title slide (title, subtitle, author), so the
--    chapter's own first level-1 heading would repeat it. Drop that heading.
local function drop_chapter_title(blocks, meta)
  if meta.title == nil then return blocks end
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      blocks:remove(i)
      break
    end
  end
  return blocks
end

function Pandoc(doc)
  local blocks = drop_chapter_title(drop_rules(doc.blocks), doc.meta)
  doc.blocks = demote_level1_with_content(blocks)
  return doc
end
