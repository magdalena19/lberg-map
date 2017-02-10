require 'mass_seed_points'

describe MassSeedPoints do
  it 'can generate 1 point in Berlin Lichtenberg' do
    expect {
      MassSeedPoints.generate(number_of_points: 1, city: 'Berlin, Lichtenberg')
    }.to change { Place.count }.by(1)
  end

  it '0 as points parameter creates no' do
    expect {
      MassSeedPoints.generate(number_of_points: 0, city: 'Berlin, Lichtenberg')
    }.to change { Place.count }.by(0)
  end

  it 'No Region returns error message' do
    expect{
      MassSeedPoints.generate(number_of_points: 0, city: '')
    }.to raise_error(ArgumentError)
  end
end
