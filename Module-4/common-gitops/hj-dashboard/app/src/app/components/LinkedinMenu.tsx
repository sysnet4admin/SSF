import {
    Menu,
    MenuHandler,
    MenuList,
    MenuItem,
  } from "@material-tailwind/react";
import Image from 'next/image';
import logo from '../../../public/linkedin.svg';

interface DetailProps {
  name: string;
  url: string;
}

const LinkedinDetail = (prop: DetailProps) => {
  return (
    <>
    <a href={prop.url} className="text-gray-900">
      {prop.name}
    </a>
    </>
  )
}

interface LinkedinMenuProps {
  data?: DetailProps[],
}
   
const LinkedinMenu = (props: LinkedinMenuProps) => {
    return (
      <Menu offset={12} allowHover>
        <MenuHandler className="flex items-center justify-between">
        <MenuItem className="flex items-center py-5 px-2 text-gray-900" placeholder={undefined} onPointerEnterCapture={undefined} onPointerLeaveCapture={undefined}>
            <Image src={logo} alt="linkedin" className="w-6 h-6 mr-1.5"></Image>Linkedin 
        </MenuItem>
        </MenuHandler>
        <MenuList className="min-w-32 flex-col items-center justify-between" placeholder={undefined} onPointerEnterCapture={undefined} onPointerLeaveCapture={undefined}>
          { props.data && props.data.length != 0 && 
            props.data.map((detailProp: DetailProps) => (
              <MenuItem className="flex-none w-full h-12" key={detailProp.name} placeholder={undefined} onPointerEnterCapture={undefined} onPointerLeaveCapture={undefined}>
                <LinkedinDetail name={detailProp.name} url={detailProp.url} />
              </MenuItem>
            ))
          }
        </MenuList>
      </Menu>
    );
}

export default LinkedinMenu;
  