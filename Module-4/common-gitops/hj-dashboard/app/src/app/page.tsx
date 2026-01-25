'use client';
import { ResponsiveCalendar } from '@nivo/calendar';
import Image from 'next/image'
import Banner from '../../public/jenkins.webp';
import { Player } from '@lottiefiles/react-lottie-player';
import json from '../../public/animation.json';
import ghIcon from '../../public/github.svg';
import LinkedinMenu from './components/LinkedinMenu';

const phase = process.env.NEXT_PUBLIC_PHASE;

const getYYYYMMDD = (date: Date) => date.toISOString().split('T')[0];

function generateRandomData(startDate: Date, endDate: Date): Data[] {
  const data = [];
  const millisecondsUnit = 1000
  const dayPeriod = 86400;
  const bias = Math.random() * 5000;
  const resolution = Math.floor(Math.random() * bias);

  let cursor = startDate.getTime() / millisecondsUnit;
  for (let i = 0; i < resolution; i++) {
    cursor += dayPeriod;
    if (cursor > endDate.getTime() / millisecondsUnit) break;
    data.push(
      { value: Math.floor(Math.random() * 100),
        day: new Date(cursor * millisecondsUnit).toISOString().split('T')[0]
    })
  }


  return data;
}

type Data = {
  value: number;
  day: string;
};

type CalendarProps = {
  data: Data[];
  startDate: Date;
  endDate: Date;
  width?: number;
  height?: number;
};

const authors = [
  {'name': 'Hoon Jo', url: 'https://www.linkedin.com/in/hoonjo/'},
  {'name': 'Gnu Shim', url: 'https://www.linkedin.com/in/gnu-shim/'},
  {'name': 'Sungmin Lee', url: 'https://www.linkedin.com/in/sungmincs/'},
  {'name': 'Seongju Mun', url: 'https://www.linkedin.com/in/seongjuishere/'},
]

const Calendar = ({ data, startDate, endDate, width, height }: CalendarProps) => (
  
  <ResponsiveCalendar
      data={data}
      from={getYYYYMMDD(startDate)}
      to={getYYYYMMDD(endDate)}
      emptyColor="#ffffff"
      colors ={phase == 'blue' ? ['#ebedf0', '#c0ddf9', '#73b3f3', '#3886e1', '#17459e'] : ['#ebedf0', '#c6e48b', '#7bc96f', '#239a3b', '#196127']}
      margin={{ top: 10, right: 10, bottom: 10, left: 10 }}
      yearSpacing={60}
      monthBorderColor="#ffffff"
      dayBorderWidth={1}
      dayBorderColor="#ffffff"
      legends={[
          {
              anchor: 'bottom-right',
              direction: 'row',
              translateY: 36,
              itemCount: 4,
              itemWidth: 42,
              itemHeight: 36,
              itemsSpacing: 14,
              itemDirection: 'right-to-left'
          }
      ]}
  />
)

export default function Home() {
  const randBetween = (min: number, max: number) => Math.floor(Math.random() * (max - min + 1) + min);

  const start = (date: Date) => new Date(date.getFullYear(), 0, randBetween(10,31)); 
  const startDate = start(new Date());
  const endDate = new Date(startDate.getFullYear(), 11, 31);
  const feedData = generateRandomData(startDate, endDate);
  return (
  <div className="flex flex-col justify-center items-center w-full h-full content-center">
    <header className='flex-0 w-full bg-white border-b border-gray-200 body-font'>
      <div className="container mx-auto flex flex-wrap p-5 flex-col md:flex-row items-center">
          <div
            className="flex title-font font-medium items-center text-gray-900 mb-4 md:mb-0">
            <Image src={Banner} alt="banner" className="w-10 h-10 mr-1" />
            <span className={`ml-3 text-xl text-${phase}-500`}>CI/CD 체험하기</span>
          </div>
          <nav className="md:ml-auto flex flex-wrap items-center text-base justify-center">
            <div className="mr-5 hover:text-gray-900">
              <LinkedinMenu data={authors} />
            </div>
            <div className="mr-2 hover:text-gray-900">
              <a className='flex items-center py-5 px-2 text-gray-900' href='https://github.com/sysnet4admin/_book_k8sinfra'>
                <Image src={ghIcon} alt="github" className="w-6 h-6 mr-2" />Github
              </a>
            </div>
          </nav>
    </div>
    </header>
    <div className={`font-sans text-7xl p-4 m-6 text-${phase}-700 basis-1/8`}>
      Hello Blue Green!
    </div>
    <div className='flex-1'>
    <Player
      autoplay
      loop
      src={json}
      style={{ height: '300px', width: '300px' }}/>
    </div>
    <div className="flex-1 w-9/12 h-14 ">
      <Calendar data={feedData} startDate={startDate} endDate={endDate} />
    </div>
  </div>
  );
}
