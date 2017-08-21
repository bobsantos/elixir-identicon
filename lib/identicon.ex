defmodule Identicon do
  @moduledoc """
    _ _ _ _ _ _ _ _ _ _ _ _ _ 
    |  1 |  2 |  3 |  2 |  1 |
    - - - - - - - - - - - - - 
    |  4 |  5 |  6 |  5 |  4 |
    - - - - - - - - - - - - - 
    |  7 |  8 |  9 |  8 |  7 |
    - - - - - - - - - - - - -
    | 10 | 11 | 12 | 11 | 10 |
    - - - - - - - - - - - - -
    | 13 | 14 | 15 | 14 | 13 |
    - - - - - - - - - - - - -

    even cells are colored and odd cells are not.
  """
  def main(input) do
    input
      |> hash_input
      |> pick_color
      |> grid
      |> build_pixel_map
      |> draw_image
      |> save(input)
  end

  def hash_input(string) do
    seed = 
      :crypto.hash(:md5, string)
        |> :binary.bin_to_list

    %Identicon.Image{seed: seed}
  end

  def pick_color(%Identicon.Image{seed: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def grid(%Identicon.Image{seed: seed} = image) do
    grid = 
      seed
        |> Enum.chunk_every(3)
        |> Enum.drop(-1)
        |> Enum.map(&mirror_row/1) 
        |> List.flatten
        |> Enum.with_index
        |> Enum.filter(fn ({code, _}) -> rem(code, 2) == 0 end)

    %Identicon.Image{image | grid: grid}
  end 

  def mirror_row([first, second | _] = row) do
    row ++ [second, first]
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    canvas = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) -> 
      :egd.filledRectangle(canvas, start, stop, fill)
    end

    :egd.render(canvas)
  end

  def save(image, filename) do
    File.write("#{filename}.png", image)
  end
end
